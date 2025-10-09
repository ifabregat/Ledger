defmodule Ledger.Repo.Migrations.CrearTransacciones do
  use Ecto.Migration

  def change do
    create table(:transacciones) do
      add :monto, :float, null: false
      add :tipo, :string, null: false

      add :cuenta_origen_id, references(:usuarios, on_delete: :restrict)
      add :moneda_origen_id, references(:monedas, on_delete: :restrict)
      add :cuenta_destino_id, references(:usuarios, on_delete: :restrict), null: false
      add :moneda_destino_id, references(:monedas, on_delete: :restrict), null: false

      timestamps()
    end

    create index(:transacciones, [:cuenta_origen_id])
    create index(:transacciones, [:moneda_origen_id])
    create index(:transacciones, [:cuenta_destino_id])
    create index(:transacciones, [:moneda_destino_id])
  end
end
