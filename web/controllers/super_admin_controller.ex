defmodule Bep.SuperAdminController do
  use Bep.Web, :controller
  alias Bep.{Client, Repo}

  def index(conn, _params) do
    render(conn, "index.html", hide_navbar: true)
  end

  def new(conn, _params) do
    changeset = Client.changeset(%Client{})
    render(conn, "new.html", changeset: changeset, hide_navbar: true)
  end

  def create(conn, %{"client" => clientMap}) do
    changeset = Client.changeset(%Client{}, clientMap)

    case Repo.insert(changeset) do
      {:ok, _entry} ->
        redirect(conn, to: super_admin_path(conn, :index))
      {:error, changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end
end
