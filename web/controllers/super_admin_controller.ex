defmodule Bep.SuperAdminController do
  use Bep.Web, :controller
  alias Bep.{Client, Repo}

  def index(conn, _params) do
    clients = Repo.all(Client)
    render(conn, "index.html", hide_navbar: true, clients: clients)
  end

  def new(conn, _params) do
    changeset = Client.changeset(%Client{})
    render(conn, "new.html", changeset: changeset, hide_navbar: true)
  end

  def create(conn, %{"client" => client_map}) do
    changeset = Client.changeset(%Client{}, client_map)

    case Repo.insert(changeset) do
      {:ok, _entry} ->
        redirect(conn, to: super_admin_path(conn, :index))
      {:error, changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => client_id}) do
    client = Repo.get(Client, client_id)
    changeset = Client.changeset(client)

    render(
      conn,
      "edit.html",
      client: client,
      changeset: changeset,
      hide_navbar: true
    )
  end

  def update(conn, %{"id" => client_id, "client" => client_map}) do
    client = Repo.get(Client, client_id)
    changeset = Client.changeset(client, client_map)

    case Repo.update(changeset) do
      {:ok, _entry} ->
        redirect(conn, to: super_admin_path(conn, :index))
      {:error, changeset} ->
        render(
          conn,
          "edit.html",
          client: client,
          changeset: changeset,
          hide_navbar: true
        )
    end
  end
end
