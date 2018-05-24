defmodule Bep.SettingsController do
  use Bep.Web, :controller
  alias Bep.{User, Type}

  def index(conn, _params) do
    user =
      User
      |> Repo.get(conn.assigns.current_user.id)
      |> Repo.preload(:types)

    user_types =
      Type
      |> Repo.all()
      |> Type.filter_super_admin

    types =
      user_types
      |> Enum.map(fn(t) ->
        %{
          id: t.id,
          type: t.type,
          checked: Enum.any?(user.types, fn(ut) -> t.id == ut.id end)
        }
      end)
    btn_colour = get_client_colour(conn, :btn_colour)

    render(
      conn,
      "index.html",
      types: types,
      changeset: user,
      btn_colour: btn_colour
    )
  end
end
