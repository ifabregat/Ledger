defmodule Ledger.Repo.Migrations.CrearTransacciones do
  use Ecto.Migration

  def change do
    create table(:transacciones) do
      add :monto, :float, null: false
      add :tipo, :string, null: false
      add :cuenta_origen_id, references(:usuarios), null: false
      add :cuenta_destino_id, references(:usuarios), null: false
      add :moneda_origen_id, references(:monedas), null: false
      add :moneda_destino_id, references(:monedas), null: false
      timestamps()
    end
  end
end
