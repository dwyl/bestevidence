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

  scope "/super-admin", Bep do
    pipe_through [:browser, :authenticate_super_admin]

    resources "/", SuperAdminController, only: [:index, :new, :create]
  end

  scope "/", Bep do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController
    resources "/sessions", SessionController, only: [:new, :create]
    resources "/consent", ConsentController, only: [:index]
    resources "/about", AboutController, only: [:index]
    resources "/password", PasswordController, only: [:index]
    post "/password/request", PasswordController, :request
    get "/password/reset", PasswordController, :reset
    post "/password/reset", PasswordController, :reset
  end

  scope "/", Bep do
    pipe_through [:browser, :authenticate_user]

    resources "/history", HistoryController, only: [:index]
    resources "/search", SearchController, only: [:index, :create]
    post "/search/category", SearchController, :filter
    resources "/notes", NoteController, only: [:index]
    resources "/settings", SettingsController, only: [:index]
    get "/password/change", PasswordController, :change_password
    post "/password/change", PasswordController, :change_password
  end

  scope "/note", Bep do
    pipe_through [:browser, :authenticate_user]
    resources "/search", NoteSearchController
    resources "/publication", NotePublicationController
  end

  # Other scopes may use custom stacks.
  scope "/", Bep do
    pipe_through :api
    resources "/publication", PublicationController, only: [:create]
    get "/load", SearchController, :load
  end

  scope "/:client_slug", Bep do
    pipe_through [:browser, :authenticate_client]

    get "/", PageController, :index
  end
end
