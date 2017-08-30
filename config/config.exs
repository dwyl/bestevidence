# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :bep,
  ecto_repos: [Bep.Repo]

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

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
