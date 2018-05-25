defmodule Bep.UserController do
  use Bep.Web, :controller
  alias Bep.{Auth, Client, Type, User}
  alias Ecto.Changeset

  def new(conn, _params) do
    types =
      Type
      |> Repo.all()
      |> Type.filter_super_admin()

    changeset = User.changeset(%User{})
    bg_colour = get_client_colour(conn, :login_page_bg_colour)
    btn_colour = get_client_colour(conn, :btn_colour)

    render(
      conn,
      "new.html",
      changeset: changeset,
      types: types,
      bg_colour: bg_colour,
      btn_colour: btn_colour
    )
  end

  def create(conn, %{"user" => user_params}) do
    bg_colour = get_client_colour(conn, :login_page_bg_colour)
    btn_colour = get_client_colour(conn, :btn_colour)

    types =
      Type
      |> Repo.all()
      |> Type.filter_super_admin()

    user_types =
      types
      |> Enum.filter(fn(t) ->
        user_params["#{t.id}"] == "true"
      end)

    client = conn.assigns.client

    user_changeset =
      %User{}
      |> User.registration_changeset(user_params)
      |> Changeset.put_assoc(:types, user_types)
      |> Changeset.put_assoc(:client, client)

    case Repo.insert(user_changeset) do
      {:ok, user} ->
        conn
        |> Auth.login(user)
        |> put_flash(:info, "Welcome to BestEvidence!")
        |> redirect(to: page_path(conn, :index))
      {:error, %{errors: [email: {"has already been taken", []}]}} ->
        conn
        |> redirect(to: session_path(conn, :new))
      {:error, changeset} ->
        render(
          conn,
          "new.html",
          changeset: changeset,
          types: types,
          bg_colour: bg_colour,
          btn_colour: btn_colour
        )
    end
  end

  def update(conn, %{"types" => types_params}) do
    types =
      Type
      |> Repo.all()
      |> Type.filter_super_admin

    user_types =
      types
      |> Enum.filter(fn(t) ->
        types_params["#{t.id}"] == "true"
      end)

    user =
      User
      |> Repo.get(conn.assigns.current_user.id)
      |> Repo.preload(:types)

    changeset =
      user
      |> Changeset.change()
      |> Changeset.put_assoc(:types, user_types)

    Repo.update!(changeset)
    redirect(conn, to: page_path(conn, :index))
  end

  def delete(conn, _) do
    client_slug = conn.assigns.client.slug
    path =
      if client_slug == "default" do
        page_path(conn, :index)
      else
        client_slug_page_path(conn, :index, client_slug)
      end

    conn
    |> Auth.logout()
    |> redirect(to: path)
 end
end
