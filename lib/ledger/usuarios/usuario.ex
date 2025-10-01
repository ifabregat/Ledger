defmodule Ledger.Usuarios.Usuario do
  use Ecto.Schema
  import Ecto.Changeset

  schema "usuarios" do
    field :nombre, :string
    field :fecha_nacimiento, :date
    timestamps()
  end

  def changeset(usuario, attrs) do
    usuario
    |> cast(attrs, [:nombre, :fecha_nacimiento])
    |> validate_required([:nombre, :fecha_nacimiento])
    |> validate_length(:nombre, min: 1)
    |> unique_constraint(:nombre)
    |> validar_mayor_edad(:fecha_nacimiento)
  end

  defp validar_mayor_edad(changeset, field) do
    case get_field(changeset, field) do
      nil -> changeset
      fecha ->
        if Date.diff(Date.utc_today(), fecha) / 365 >= 18 do
          changeset
        else
          add_error(changeset, field, "El usuario debe ser mayor de edad")
        end
    end
  end
end
