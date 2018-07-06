defmodule Bep.UserController do
  use Bep.Web, :controller
  alias Bep.{Auth, OtherType, Type, User}
  alias Ecto.Changeset

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    assets = get_assets(conn, changeset)
    render(conn, "new.html", assets)
  end

  def create(conn, %{"user" => user_params}) do
    email = user_params["email"]
    client = conn.assigns.client
    other_type = user_params["other_type"]

    user_types =
      Type.get_types()
      |> Enum.filter(fn(t) ->
        user_params["#{t.id}"] == "true"
      end)

    user_changeset =
      %User{}
      |> User.registration_changeset(user_params)
      |> Changeset.put_assoc(:types, user_types)
      |> Changeset.put_assoc(:client, client)

    if contains_other?(user_types) && other_type == "" do
      assets = get_assets(conn, user_changeset)
      render(conn, "new.html", assets)
    else
      case Repo.insert(user_changeset) do
        {:ok, user} ->
          Repo.insert(%OtherType{user_id: user.id, type: other_type})
          conn
          |> Auth.login(user)
          |> put_flash(:info, "Welcome to BestEvidence!")
          |> redirect(to: page_path(conn, :index))
        {:error, %{errors: [email: {"has already been taken", []}]}} ->
          slug = conn.assigns.client.slug
          path =
            case slug do
              "default" ->
                session_path(conn, :new)
              _ ->
                client_slug_session_path(conn, :new, slug)
            end
          redirect(conn, to: path)
        {:error, changeset} ->
          changeset = Changeset.put_change(changeset, :email, email)
          assets = get_assets(conn, changeset)
          render(conn, "new.html", assets)
      end
    end
  end

  def update(conn, %{"types" => types_params}) do
    other_type = types_params["other_type"]

    user =
      User
      |> Repo.get(conn.assigns.current_user.id)
      |> Repo.preload(:types)

    user_types =
      Type.get_types()
      |> Enum.filter(fn(t) ->
        types_params["#{t.id}"] == "true"
      end)

    changeset =
      user
      |> Changeset.change()
      |> Changeset.put_assoc(:types, user_types)

    Repo.update!(changeset)
    Repo.delete_all(from(ot in OtherType, where: ot.user_id == ^user.id))
    Repo.insert!(%OtherType{user_id: user.id, type: other_type})
    redirect(conn, to: page_path(conn, :index))
  end

  def delete(conn, _) do
    path =
      case conn.assigns.client.slug do
        "default" ->
          page_path(conn, :index)
        slug ->
          client_slug_page_path(conn, :index, slug)
      end

    conn
    |> Auth.logout()
    |> redirect(to: path)
  end

  defp get_assets(conn, changeset) do
    types = Type.get_types()
    {other, types} = Type.separate_other(types)
    bg_colour = get_client_colour(conn, :login_page_bg_colour)
    btn_colour = get_client_colour(conn, :btn_colour)

    [
      changeset: changeset,
      types: types,
      other: other,
      bg_colour: bg_colour,
      btn_colour: btn_colour
    ]
  end

  defp contains_other?(list) do
    Enum.any?(list, &(&1.type == "other"))
  end
end
