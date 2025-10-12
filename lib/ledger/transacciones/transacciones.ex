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
end
