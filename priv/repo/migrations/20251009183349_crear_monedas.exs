defmodule Ledger.Repo.Migrations.CrearMonedas do
  use Ecto.Migration

  def change do
    create table(:monedas) do
      add :nombre, :string, null: false
      add :precio_dolares, :float, null: false

      timestamps()
    end

    create unique_index(:monedas, [:nombre])

    create constraint(:monedas, :precio_dolares_mayor_que_cero, check: "precio_dolares > 0")
  end
end
