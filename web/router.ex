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

  scope "/super-admin", Bep, as: :sa do
    pipe_through [:browser, :authenticate_super_admin]

    resources "/", SuperAdminController, only: [
      :index, :new, :create, :edit, :update
    ]
    get "/new-client-admin", SuperAdminController, :new_client_admin
    post "/create-client-admin", SuperAdminController, :create_client_admin
    get "/edit-client-admin", SuperAdminController, :edit_client_admin
    put "/update-client-admin/:id", SuperAdminController, :update_client_admin
    get "/list-users", MessagesController, :list_users
    post "/list-users", MessagesController, :view_user_messages
    get "/messages", MessagesController, :view_messages
    get "/message_sent", MessagesController, :message_sent
    resources "/messages", MessagesController, only: [:create, :new]
  end

  scope "/", Bep, as: :ca do
    pipe_through [:browser, :authenticate_ca]
    get "/list-users", MessagesController, :list_users
    post "/list-users", MessagesController, :view_user_messages
    get "/message_sent", MessagesController, :message_sent
    resources "/messages", MessagesController, only: [:create, :new]
  end

  scope "/", Bep do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    post "/cat", PageController, :cat
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

    get "/paper-details", BearController, :paper_details
    get "/check-validity", BearController, :check_validity
    get "/calculate-results", BearController, :calculate_results
    get "/relevance", BearController, :relevance
    get "/bear-complete", BearController, :complete
    resources "/bears", BearController, only: [:index]
    resources "/bear-form", BearController, only: [:create]
    resources "/pico", PicoSearchController, [:new, :create, :edit]
    resources "/history", HistoryController, only: [:index]
    resources "/search", SearchController, only: [:index, :create]
    post "/search/category", SearchController, :filter
    resources "/settings", SettingsController, only: [:index]
    get "/password/change", PasswordController, :change_password
    post "/password/change", PasswordController, :change_password
    get "/messages", MessagesController, :view_messages
  end

  scope "/note", Bep do
    pipe_through [:browser, :authenticate_user]
    resources "/search", NoteSearchController
  end

  # Other scopes may use custom stacks.
  scope "/", Bep do
    pipe_through :api
    resources "/publication", PublicationController, only: [:create]
    get "/load", SearchController, :load
  end

  scope "/:client_slug", Bep, as: :client_slug do
    pipe_through [:browser, :authenticate_client]

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
end
