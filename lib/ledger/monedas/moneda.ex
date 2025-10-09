defmodule Ledger.Monedas.Moneda do
  use Ecto.Schema
  import Ecto.Changeset

  schema "monedas" do
    field :nombre, :string
    field :precio_dolares, :float

    has_many :transacciones_origen, Ledger.Transacciones.Transaccion,
      foreign_key: :moneda_origen_id

    has_many :transacciones_destino, Ledger.Transacciones.Transaccion,
      foreign_key: :moneda_destino_id

    timestamps()
  end

  def changeset(moneda, attrs) do
    moneda
    |> cast(attrs, [:nombre, :precio_dolares])
    |> validate_required([:nombre, :precio_dolares])
    |> unique_constraint(:nombre, message: "El nombre de la moneda ya está en uso")
    |> validate_length(:nombre,
      min: 3,
      max: 4,
      message: "El nombre debe tener entre 3 y 4 caracteres"
    )
    |> validate_format(:nombre, ~r/^[A-Z]+$/,
      message: "El nombre debe contener solo letras mayúsculas"
    )
    |> validate_number(:precio_dolares,
      greater_than_or_equal_to: 0.0,
      message: "El precio en dólares debe ser un número no negativo"
    )
    |> validar_inmutabilidad_nombre()
  end

  defp validar_inmutabilidad_nombre(changeset) do
    if get_field(changeset, :id) && get_change(changeset, :nombre) do
      add_error(changeset, :nombre, "El nombre de la moneda no puede ser modificado")
    else
      changeset
    end
  end
end
