# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :bep,
  ecto_repos: [Bep.Repo],
  mailgun_api_key: System.get_env("MAILGUN_API_KEY"),
  mailgun_domain: System.get_env("MAILGUN_DOMAIN"),
  base_url: "https://www.bestevidence.info",
  httpoison: HTTPoison


# Configures the endpoint
config :bep, Bep.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  tripdatabase_key: System.get_env("TRIPDATABASE_KEY"),
  render_errors: [view: Bep.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Bep.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure mailing
config :bep, Bep.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: System.get_env("SES_SERVER"),
  port: System.get_env("SES_PORT"),
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  tls: :always, # can be `:always` or `:never`
  ssl: false, # can be `true`
  retries: 1

config :bep, :ex_aws, ExAws

# Configure aws
config :ex_aws,
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
  s3: [
    scheme: "https://",
    host: "#{System.get_env("AWS_BUCKET")}.s3.amazonaws.com",
    region: System.get_env("AWS_REGION")
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
