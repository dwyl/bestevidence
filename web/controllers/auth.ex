defmodule Bep.Auth do
  @moduledoc """
  Plug which check for each request if a user is authenticated
  """
  import Plug.Conn
  import Phoenix.Controller
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  alias Bep.{Client, Repo, User}
  alias Bep.Router.Helpers
  alias Phoenix.Token
  alias Bep.User

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    default = repo.get_by(Bep.Client, name: "default")
    conn = assign(conn, :client, default)
    cond do
      user = conn.assigns[:current_user] ->
        put_current_user(conn, user)
      user = user_id && repo.get(User, user_id) ->
        put_current_user(conn, user)
      true ->
        assign(conn, :current_user, nil)
    end
  end

  def authenticate_client(conn, _opts) do
    client_slug =
      conn.params["client_slug"]
      |> String.downcase()

    client =
      if client_slug == "default" do
        false
      else
        Repo.get_by(Client, slug: client_slug)
      end

    if client do
      assign(conn, :client, client)
    else
      conn
      |> text("page not found")
      |> halt()
    end
  end

  def authenticate_super_admin(conn, _opts)do
    user = Repo.preload(conn.assigns.current_user, :types)
    is_super_admin_bool =
      if user != nil do
        Enum.any?(user.types, &(&1.type == "super-admin"))
      else
        false
      end

      if is_super_admin_bool do
        conn
      else
        conn
        |> put_flash(:error, "You must be logged in to access that page")
        |> redirect(to: Helpers.page_path(conn, :index))
        |> halt()
      end
  end

  def authenticate_user(conn, _opts)do
    user = Repo.preload(conn.assigns.current_user, :types)

    is_super_admin_bool =
      if user != nil do
        Enum.any?(user.types, &(&1.type == "super-admin"))
      else
        false
      end

    cond do
      is_super_admin_bool ->
        conn
        |> redirect(to: Helpers.super_admin_path(conn, :index))
        |> halt()
      user ->
        client = Repo.get(Client, user.client_id)
        assign(conn, :client, client)
      true ->
        conn
        |> put_flash(:error, "You must be logged in to access that page")
        |> redirect(to: Helpers.page_path(conn, :index))
        |> halt()
    end
  end

  def login(conn, user) do
    conn
    |> put_current_user(user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  defp put_current_user(conn, user) do
    token = Token.sign(conn, "user socket", user.id)

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end

  def login_by_email_and_pass(conn, email, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    hashed_email =
      email
      |> String.downcase()
      |> User.hash_str()
    user = repo.get_by(User, email: hashed_email)

    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end
end
