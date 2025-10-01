defmodule Ledger.Monedas.Moneda do
  use Ecto.Schema
  import Ecto.Changeset

  schema "monedas" do
    field :nombre, :string
    field :precio, :float
    timestamps()
  end

  def changeset(moneda, attrs) do
    moneda
    |> cast(attrs, [:nombre, :precio])
    |> validate_required([:nombre, :precio])
    |> validate_number(:precio, greater_than_or_equal_to: 0)
    |> validate_length(:nombre, min: 3, max: 4)
    |> validate_format(:nombre, ~r/^[A-Z]+$/)
    |> unique_constraint(:nombre)
    |> validar_inmutabilidad_nombre()
  end

  defp validar_inmutabilidad_nombre(changeset) do
    if get_change(changeset, :nombre) && changeset.data.id do
      add_error(changeset, :nombre, "El nombre no puede editarse")
    else
      changeset
    end
  end
end
