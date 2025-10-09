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
  end
end
