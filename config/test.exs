use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :renaissance, RenaissanceWeb.Endpoint,
  http: [port: 4002],
  server: false

# Reduce test run time
config :bcrypt_elixir, log_rounds: 4
config :comeonin, :bcrypt_log_rounds, 4

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :renaissance, Renaissance.Repo,
  username: "postgres",
  password: "postgres",
  database: "renaissance_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
