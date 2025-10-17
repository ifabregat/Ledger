defmodule Ledger.Transacciones.Transacciones do
  import Ecto.Query
  alias Ledger.Repo
  alias Ledger.Transacciones.Transaccion
  alias Ledger.Usuarios.Usuario
  alias Ledger.Monedas.Moneda

  def alta_cuenta(attrs) do
    case Repo.get(Usuario, attrs.cuenta_destino_id) do
      nil ->
        {:error, "Usuario no encontrado"}

      usuario ->
        case Repo.get(Moneda, attrs.moneda_destino_id) do
          nil ->
            {:error, "Moneda no encontrada"}

          moneda ->
            if existe_alta?(usuario.id, moneda.id) do
              {:error, "El usuario ya tiene una cuenta en esta moneda"}
            else
              %Transaccion{}
              |> Transaccion.alta_changeset(%{
                monto: attrs.monto,
                tipo: attrs.tipo,
                cuenta_destino_id: usuario.id,
                moneda_destino_id: moneda.id
              })
              |> Repo.insert()
            end
        end
    end
  end

  defp existe_alta?(usuario_id, moneda_id) do
    Repo.exists?(
      from t in Transaccion,
        where:
          t.tipo == "alta" and
            t.cuenta_destino_id == ^usuario_id and
            t.moneda_destino_id == ^moneda_id
    )
  end

  def realizar_transferencia(attrs) do
    if attrs.cuenta_origen_id == attrs.cuenta_destino_id do
      {:error, "El usuario origen y destino no pueden ser el mismo"}
    else
      Repo.transaction(fn ->
        origen = Repo.get!(Usuario, attrs.cuenta_origen_id)
        destino = Repo.get!(Usuario, attrs.cuenta_destino_id)
        moneda = Repo.get!(Moneda, attrs.moneda_origen_id)

        unless saldo_suficiente?(origen.id, moneda.id, attrs.monto) do
          Repo.rollback("Saldo insuficiente")
        end

        %Transaccion{}
        |> Transaccion.transferencia_changeset(%{
          monto: attrs.monto,
          tipo: attrs.tipo,
          cuenta_origen_id: origen.id,
          moneda_origen_id: moneda.id,
          cuenta_destino_id: destino.id,
          moneda_destino_id: moneda.id
        })
        |> Repo.insert!()
      end)
    end
  end

  defp saldo_suficiente?(usuario_id, moneda_id, monto) do
    entradas =
      Repo.one(
        from t in Transaccion,
          where:
            (t.tipo == "alta" or t.cuenta_destino_id == ^usuario_id) and
              t.moneda_destino_id == ^moneda_id,
          select: sum(t.monto)
      ) || 0

    salidas =
      Repo.one(
        from t in Transaccion,
          where: t.cuenta_origen_id == ^usuario_id and t.moneda_origen_id == ^moneda_id,
          select: sum(t.monto)
      ) || 0

    saldo_actual = entradas - salidas

    saldo_actual >= monto
  end

  def realizar_swap(attrs) do
    Repo.transaction(fn ->
      usuario = Repo.get!(Usuario, attrs.cuenta_destino_id)
      moneda_origen = Repo.get!(Moneda, attrs.moneda_origen_id)
      moneda_destino = Repo.get!(Moneda, attrs.moneda_destino_id)

      if moneda_origen.id == moneda_destino.id do
        Repo.rollback("La moneda de origen y destino no pueden ser la misma")
      end

      if not saldo_suficiente?(usuario.id, moneda_origen.id, attrs.monto) do
        Repo.rollback("Saldo insuficiente para realizar el swap")
      end

      %Transaccion{}
      |> Transaccion.swap_changeset(%{
        tipo: "swap",
        cuenta_destino_id: usuario.id,
        moneda_origen_id: moneda_origen.id,
        moneda_destino_id: moneda_destino.id,
        monto: attrs.monto
      })
      |> Repo.insert!()
    end)
  end

  def deshacer_transaccion(attrs) do
    Repo.transaction(fn ->
      case Repo.get(Transaccion, attrs.id) do
        nil ->
          Repo.rollback("Transacción no encontrada")

        transaccion ->
          tipo = normalizar_tipo(transaccion.tipo)

          if ultima_transaccion?(transaccion) do
            case tipo do
              :alta ->
                Repo.delete!(transaccion)

              :transferencia ->
                inversa = construir_inversa(:transferencia, transaccion)
                Repo.insert!(inversa)

              :swap ->
                inversa = construir_inversa(:swap, transaccion)
                Repo.insert!(inversa)

              _ ->
                Repo.rollback("No se puede deshacer este tipo de transacción")
            end
          else
            Repo.rollback("Solo se puede deshacer la última transacción de las cuentas")
          end
      end
    end)
  end

  defp normalizar_tipo(tipo) when is_binary(tipo) do
    case tipo do
      "transferencia" -> :transferencia
      "swap" -> :swap
      "alta" -> :alta
      _ -> :desconocido
    end
  end

  defp construir_inversa(:transferencia, t) do
    %Transaccion{
      tipo: "transferencia",
      monto: t.monto,
      cuenta_origen_id: t.cuenta_destino_id,
      moneda_origen_id: t.moneda_destino_id,
      cuenta_destino_id: t.cuenta_origen_id,
      moneda_destino_id: t.moneda_origen_id
    }
  end

  defp construir_inversa(:swap, t) do
    %Transaccion{
      tipo: "swap",
      monto: t.monto,
      cuenta_destino_id: t.cuenta_destino_id,
      moneda_origen_id: t.moneda_destino_id,
      moneda_destino_id: t.moneda_origen_id
    }
  end

  defp ultima_transaccion?(transaccion) do
    origen = transaccion.cuenta_origen_id
    destino = transaccion.cuenta_destino_id

    query =
      if origen do
        from t in Transaccion,
          where: t.cuenta_origen_id == ^origen or t.cuenta_destino_id == ^destino,
          order_by: [desc: t.id],
          limit: 1
      else
        from t in Transaccion,
          where: t.cuenta_destino_id == ^destino,
          order_by: [desc: t.id],
          limit: 1
      end

    case Repo.one(query) do
      nil -> false
      ultima -> ultima.id == transaccion.id
    end
  end

  def ver_transaccion(attrs) do
    case Repo.get(Transaccion, attrs.id) do
      nil -> {:error, "Transacción no encontrada"}
      transaccion -> {:ok, transaccion}
    end
  end
end
