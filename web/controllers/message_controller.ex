defmodule Bep.MessageController do
  use Bep.Web, :controller
  alias Bep.{User}

  def index(conn, _params) do
    user = Repo.preload(conn.assigns.current_user, :types)
    admin_bool = is_admin?(user)
    user_list = get_user_list(admin_bool)
    render(
      conn,
      :index,
      [
        admin_bool: admin_bool,
        hide_navbar: admin_bool,
        user_list: user_list
      ]
    )
  end

  defp is_admin?(user) do
    if Enum.any?(user.types, &(&1.type == "super-admin" || &1.type == "client-admin")) do
      true
    else
      false
    end
  end

  defp get_user_list(bool) do
    query =
      from u in User,
      join: t in assoc(u, :types),
      where: t.type != "super-admin"
    if bool do
      Repo.all(query)
    else
      []
    end
  end
end
