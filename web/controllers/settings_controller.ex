defmodule Bep.SettingsController do
  use Bep.Web, :controller
  alias Bep.{OtherType, Type}

  def index(conn, _params) do
    user = conn.assigns.current_user
    types =
      Type.get_types()
      |> Enum.map(fn(t) ->
        %{
          id: t.id,
          type: t.type,
          checked: Enum.any?(user.types, fn(ut) -> t.id == ut.id end)
        }
      end)

    other_type = Repo.get_by(OtherType, user_id: user.id)

    other_value =
      case other_type do
        nil ->
          ""
        _ ->
          other_type.type
      end

    {other, types} = Type.separate_other(types)
    btn_colour = get_client_colour(conn, :btn_colour)
    assets = [
      types: types,
      other: other,
      changeset: user,
      btn_colour: btn_colour,
      other_value: other_value
    ]
    render(conn, "index.html", assets)
  end
end
