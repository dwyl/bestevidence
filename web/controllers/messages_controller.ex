defmodule Bep.MessagesController do
  use Bep.Web, :controller
  alias Bep.{Messages}

  def view_messages(conn, %{"user" => user_id}) do
    messages = Messages.get_messages(user_id)
    assigns = update_assigns(conn, [messages: messages])
    render(conn, :view, assigns)
  end

  def list_users(conn, _params) do
    users = Messages.get_user_list()
    assigns = [hide_navbar: true, users: users]
    render(conn, :list_users, assigns)
  end

  defp update_assigns(conn, list) do
    current_user_is_admin_bool =
      conn.assigns.current_user
      |> Repo.preload(:types)
      |> Map.get(:types)
      |> Messages.is_type_admin?()

    case current_user_is_admin_bool do
      true ->
        [{:hide_navbar, current_user_is_admin_bool} | list]
      _ ->
        list
    end
  end
end
