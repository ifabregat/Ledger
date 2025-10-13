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
      transaccion = Repo.get!(Transaccion, attrs.id)

      if ultima_transaccion?(String.to_existing_atom(transaccion.tipo), transaccion) do
        inversa =
          case transaccion.tipo do
            "transferencia" ->
              %Transaccion{
                tipo: "transferencia",
                monto: transaccion.monto,
                cuenta_origen_id: transaccion.cuenta_destino_id,
                moneda_origen_id: transaccion.moneda_destino_id,
                cuenta_destino_id: transaccion.cuenta_origen_id,
                moneda_destino_id: transaccion.moneda_origen_id
              }

            "swap" ->
              %Transaccion{
                tipo: "swap",
                monto: transaccion.monto,
                cuenta_destino_id: transaccion.cuenta_destino_id,
                moneda_origen_id: transaccion.moneda_destino_id,
                moneda_destino_id: transaccion.moneda_origen_id
              }

            _ ->
              Repo.rollback("Tipo de transacción no soportado para deshacer")
          end

        Repo.insert!(inversa)
      else
        Repo.rollback("Solo se puede deshacer la última transacción de las cuentas involucradas")
      end
    end)
  end

  defp ultima_transaccion?(:transferencia, transaccion) do
    ultima_origen =
      Repo.one(
        from t in Transaccion,
          where: t.cuenta_origen_id == ^transaccion.cuenta_origen_id,
          select: max(t.inserted_at)
      )

    ultima_origen == transaccion.inserted_at
  end

  defp ultima_transaccion?(:swap, transaccion) do
    ultima_destino =
      Repo.one(
        from tr in Transaccion,
          where: tr.cuenta_destino_id == ^transaccion.cuenta_destino_id,
          select: max(tr.inserted_at)
      )

    ultima_destino == transaccion.inserted_at
  end

  def ver_transaccion(attrs) do
    case Repo.get(Transaccion, attrs.id) do
      nil -> {:error, "Transacción no encontrada"}
      transaccion -> {:ok, transaccion}
    end
  end
end
