defmodule Bep.Router do
  use Bep.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Bep.Auth, repo: Bep.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Bep do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create]
    resources "/consent", ConsentController, only: [:index]
    resources "/about", AboutController, only: [:index]
  end

  scope "/", Bep do
    pipe_through [:browser, :authenticate_user]

    resources "/history", HistoryController, only: [:index]
    resources "/search", SearchController, only: [:index, :create]
  end

  # Other scopes may use custom stacks.
  scope "/", Bep do
    pipe_through :api
    resources "/publication", PublicationController, only: [:create]
    get "/load", SearchController, :load
  end
end
