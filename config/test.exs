import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :wrangler, WranglerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "4E+DzAUk9hXJaURsUMt2x8yn4UGGu+cjc1N3AffHEUcQqazSrDqAqdtIdhzD9Nij",
  server: false

# In test we don't send emails.
config :wrangler, Wrangler.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
