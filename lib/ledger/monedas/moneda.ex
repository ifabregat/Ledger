defmodule Ledger.Monedas.Moneda do
  use Ecto.Schema
  import Ecto.Changeset

  schema "monedas" do
    field :nombre, :string
    field :precio_dolares, :float

    timestamps()
  end

  def changeset(moneda, attrs) do
    moneda
    |> cast(attrs, [:nombre, :precio_dolares])
    |> validate_required([:nombre, :precio_dolares])
  end
end
