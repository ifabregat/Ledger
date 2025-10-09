defmodule Ledger.Transacciones.Transaccion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transacciones" do
    field :monto, :float
    field :tipo, :string

    belongs_to :cuenta_origen, Ledger.Usuarios.Usuario
    belongs_to :moneda_origen, Ledger.Monedas.Moneda
    belongs_to :cuenta_destino, Ledger.Usuarios.Usuario
    belongs_to :moneda_destino, Ledger.Monedas.Moneda

    timestamps()
  end

  def alta_changeset(transaccion, attrs) do
    transaccion
    |> cast(attrs, [:monto, :tipo, :cuenta_destino_id, :moneda_destino_id])
    |> validate_required([:monto, :tipo, :cuenta_destino_id, :moneda_destino_id])
    |> validate_number(:monto, greater_than: 0, message: "El monto debe ser mayor que 0")
    |> foreign_key_constraint(:cuenta_destino_id)
    |> foreign_key_constraint(:moneda_destino_id)
  end

  def transferencia_changeset(transaccion, attrs) do
    transaccion
    |> cast(attrs, [
      :monto,
      :tipo,
      :cuenta_origen_id,
      :moneda_origen_id,
      :cuenta_destino_id,
      :moneda_destino_id
    ])
    |> validate_required([
      :monto,
      :tipo,
      :cuenta_origen_id,
      :moneda_origen_id,
      :cuenta_destino_id,
      :moneda_destino_id
    ])
    |> validate_number(:monto, greater_than: 0, message: "El monto debe ser mayor que 0")
    |> foreign_key_constraint(:cuenta_origen_id)
    |> foreign_key_constraint(:moneda_origen_id)
    |> foreign_key_constraint(:cuenta_destino_id)
    |> foreign_key_constraint(:moneda_destino_id)
  end

  def swap_changeset(transaccion, attrs) do
    transaccion
    |> cast(attrs, [:monto, :tipo, :cuenta_origen_id, :moneda_origen_id, :moneda_destino_id])
    |> validate_required([:monto, :tipo, :cuenta_origen_id, :moneda_origen_id, :moneda_destino_id])
    |> validate_number(:monto, greater_than: 0, message: "El monto debe ser mayor que 0")
    |> foreign_key_constraint(:cuenta_origen_id)
    |> foreign_key_constraint(:moneda_origen_id)
    |> foreign_key_constraint(:moneda_destino_id)
  end
end
