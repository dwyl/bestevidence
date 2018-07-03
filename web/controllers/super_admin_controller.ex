defmodule Bep.SuperAdminController do
  use Bep.Web, :controller
  alias Bep.{Client, Repo}

  def index(conn, _params) do
    assigns = [hide_navbar: true, clients: Repo.all(Client)]
    render(conn, "index.html", assigns)
  end

  def new(conn, _params) do
    changeset = Client.changeset(%Client{})
    assigns = [changeset: changeset, hide_navbar: true]
    render(conn, "new.html", assigns)
  end

  def create(conn, %{"client" => client_map}) do
    client_map = client_logo_helper(client_map)
    changeset = Client.logo_changeset(%Client{}, client_map)
    case Repo.insert(changeset) do
      {:ok, _entry} ->
        redirect(conn, to: sa_super_admin_path(conn, :index))
      {:error, changeset} ->
        assigns = [changeset: changeset, hide_navbar: true]
        render(conn, "new.html", assigns)
    end
  end

  def edit(conn, %{"id" => client_id}) do
    client = Repo.get(Client, client_id)
    changeset = Client.changeset(client)
    assigns = [client: client, changeset: changeset, hide_navbar: true]
    render(conn, "edit.html", assigns)
  end

  def update(conn, %{"id" => client_id, "client" => client_map}) do
    client = Repo.get(Client, client_id)
    client_map = client_logo_helper(client_map)
    changeset = Client.logo_changeset(client, client_map)

    case Repo.update(changeset) do
      {:ok, _entry} ->
        redirect(conn, to: sa_super_admin_path(conn, :index))
      {:error, changeset} ->
        assigns = [client: client, changeset: changeset, hide_navbar: true]
        render(conn, "edit.html", assigns)
    end
  end

  def client_logo_helper(map) do
    case map["client_logo"] do
      nil ->
        Map.put(map, "client_logo", nil)
      logo ->
        logo_map = Map.from_struct(logo)
        Map.put(map, "client_logo", logo_map)
    end
  end
end
