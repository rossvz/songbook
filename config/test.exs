import Config

config :ash,
  policies: [show_policy_breakdowns?: true],
  disable_async?: true

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Disable Oban in tests
config :songbook, Oban, testing: :inline

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used

# In test we don't send emails.
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :songbook, Songbook.Mailer, adapter: Swoosh.Adapters.Test

config :songbook, Songbook.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "songbook_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  # We don't run a server during test. If one is required,
  # you can enable the server option below.
  pool_size: System.schedulers_online() * 2

config :songbook, SongbookWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "jDDCzviEEk00vLkVlDjT5YvVGjAcTPm5gpxbUW9zCt4FNHtJunAyk0aAOCHBvFEM",
  server: false

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false
