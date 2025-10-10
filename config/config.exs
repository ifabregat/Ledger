import Config

config :ledger, Ledger.Repo,
  database: "ledger",
  username: "admin",
  password: "admin123",
  hostname: "localhost"

config :ledger, ecto_repos: [Ledger.Repo]
config :ledger, Ledger.Repo, log: false
