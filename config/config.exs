import Config

config :ledger, Ledger.Repo,
  database: "ledger",
  username: "admin",
  password: "admin123",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :ledger, ecto_repos: [Ledger.Repo]
config :ledger, Ledger.Repo, log: false
