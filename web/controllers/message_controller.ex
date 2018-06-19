defmodule Bep.MessageController do
  use Bep.Web, :controller

  def index(conn, params) do
    user = Repo.preload(conn.assigns.current_user, :types)
    admin_bool = is_admin?(user)
    render(conn, :index, [admin_bool: admin_bool, hide_navbar: admin_bool])
  end

  defp is_admin?(user) do
    if Enum.any?(user.types, &(&1.type == "super-admin" || &1.type == "client_admin")) do
      true
    else
      false
    end
  end
end
