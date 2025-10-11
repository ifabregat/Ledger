defmodule Ledger.Usuarios.Usuario do
  use Ecto.Schema
  import Ecto.Changeset

  @mayor_edad 18

  schema "usuarios" do
    field :nombre, :string
    field :fecha_nacimiento, :date

    has_many :transacciones_origen, Ledger.Transacciones.Transaccion,
      foreign_key: :cuenta_origen_id

    has_many :transacciones_destino, Ledger.Transacciones.Transaccion,
      foreign_key: :cuenta_destino_id

    timestamps()
  end

  def changeset(usuario, attrs) do
    usuario
    |> cast(attrs, [:nombre, :fecha_nacimiento])
    |> validate_required([:nombre, :fecha_nacimiento])
    |> unique_constraint(:nombre, message: "El nombre ya está en uso")
    |> validar_mayor_edad()
    |> validar_cambio_nombre()
  end

  defp validar_mayor_edad(changeset) do
    case fetch_field(changeset, :fecha_nacimiento) do
      {_, fecha_nacimiento} ->
        edad = div(Date.diff(Date.utc_today(), fecha_nacimiento), 365)

        if edad < @mayor_edad do
          add_error(changeset, :fecha_nacimiento, "El usuario debe ser mayor de edad")
        else
          changeset
        end

      :error ->
        changeset
    end
  end

  defp validar_cambio_nombre(changeset) do
    if changeset.data.id do
      nuevo_nombre = Map.get(changeset.params, "nombre")
      nombre_actual = changeset.data.nombre

      if nuevo_nombre == nombre_actual do
        add_error(changeset, :nombre, "El nuevo nombre debe ser diferente al actual")
      else
        changeset
      end
    else
      changeset
    end
  end
end
