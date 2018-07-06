defmodule Bep.SuperAdminController do
  use Bep.Web, :controller
  alias Bep.{Client, Repo, Type, User}
  alias Ecto.Changeset

  def new_client_admin(conn, %{"client_id" => client_id}) do
    changeset = User.changeset(%User{})
    assigns = [hide_navbar: true, changeset: changeset, client_id: client_id]
    render(conn, "new_client_admin.html", assigns)
  end

  def create_client_admin(conn, %{"user" => %{"email" => email, "client_id" => client_id}}) do
    user_params = %{email: email, password: System.get_env("CA_PASS")}
    ca_admin_type = Repo.get_by(Type, type: "client-admin")

    client = Repo.get(Client, client_id)
    user_changeset =
      %User{}
      |> User.registration_changeset(user_params)
      |> Changeset.put_assoc(:types, [ca_admin_type])
      |> Changeset.put_assoc(:client, client)

    case Repo.insert(user_changeset) do
      {:ok, _user} ->
        redirect(conn, to: sa_super_admin_path(conn, :index))
      {:error, user_changeset} ->
        assigns = [
          hide_navbar: true,
          changeset: user_changeset,
          client_id: client.id
        ]
        render(conn, "new_client_admin.html", assigns)
    end
  end

  def edit_client_admin(conn, %{"client_admin_id" => client_admin_id}) do
    changeset = User.changeset(%User{})
    assigns = [
      hide_navbar: true,
      changeset: changeset,
      client_admin_id: client_admin_id
    ]
    render(conn, "edit_client_admin.html", assigns)
  end

  def update_client_admin(conn, %{"user" => %{"client_admin_id" => ca_id, "email" => email}}) do
    client_admin = Repo.get(User, ca_id)
    changeset = User.changeset(client_admin, %{email: email})

    case Repo.update(changeset) do
      {:ok, _entry} ->
        redirect(conn, to: sa_super_admin_path(conn, :index))
      {:error, changeset} ->
        assigns = [
          hide_navbar: true,
          changeset: changeset,
          client_admin_id: ca_id
        ]
        render(conn, "edit_client_admin.html", assigns)
    end

  end

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
    client_changeset = Client.logo_changeset(%Client{}, client_map)

    case Repo.insert(client_changeset) do
      {:ok, client} ->
        changeset = User.changeset(%User{})
        assigns = [
          hide_navbar: true,
          changeset: changeset,
          client_id: client.id
        ]
        render(conn, "new_client_admin.html", assigns)
      {:error, client_changeset} ->
        assigns = [changeset: client_changeset, hide_navbar: true]
        render(conn, "new.html", assigns)
    end
  end

  def edit(conn, %{"id" => client_id}) do
    client_admin_id = get_client_admin_id(client_id)
    client = Repo.get(Client, client_id)
    changeset = Client.changeset(client)
    assigns = [
      client_admin_id: client_admin_id,
      client: client,
      changeset: changeset,
      hide_navbar: true
    ]
    render(conn, "edit.html", assigns)
  end

  def update(conn, %{"id" => client_id, "client" => client_map}) do
    client = Repo.get(Client, client_id)
    client_map = client_logo_helper(client_map)
    client_admin_id = get_client_admin_id(client_id)

    changeset =
      case client_map["client_logo"] do
        nil ->
          Client.changeset(client, client_map)
        _ ->
          Client.logo_changeset(client, client_map)
      end

    case Repo.update(changeset) do
      {:ok, _entry} ->
        redirect(conn, to: sa_super_admin_path(conn, :index))
      {:error, changeset} ->
        assigns = [
          client_admin_id: client_admin_id,
          client: client,
          changeset: changeset,
          hide_navbar: true
        ]
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

  defp get_client_admin_id(client_id) do
    # can this be done in a single query
    query = from u in User, where: u.client_id == ^client_id
    ca_user_list =
      query
      |> Repo.all()
      |> Repo.preload(:types)
      |> Enum.filter(&Type.is_type?(&1.types, "client-admin"))

    has_client_admin_bool =
      case ca_user_list do
        [] -> false
        _ -> true
      end

    client_admin =
      case has_client_admin_bool do
        true -> hd(ca_user_list)
        _ -> []
      end

    case has_client_admin_bool do
      true -> client_admin.id
      _ -> nil
    end
  end
end
