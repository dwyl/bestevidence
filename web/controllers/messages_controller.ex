defmodule Bep.MessagesController do
  use Bep.Web, :controller
  alias Bep.{Messages, Type}

  def view_messages(conn, %{"user" => user_id}) do
    assigns = [
      messages: Messages.get_messages(user_id),
      user: user_id,
      changeset: Messages.changeset(%Messages{})
    ]
    |> hide_nav_for_SA(conn)
    render(conn, :view, assigns)
  end

  def list_users(conn, _params) do
    assigns = [
      hide_navbar: true,
      users: Messages.get_user_list()
    ]
    render(conn, :list_users, assigns)
  end


  def message_sent(conn, _params) do
    assigns = [hide_navbar: true]
    render(conn, :message_sent, assigns)
  end

  #Helpers
  defp hide_nav_for_SA(list, conn) do
    current_user_is_admin_bool =
      conn.assigns.current_user
      |> Repo.preload(:types)
      |> Map.get(:types)
      |> Type.is_type_admin?()

    case current_user_is_admin_bool do
      true ->
        [{:hide_navbar, current_user_is_admin_bool} | list]
      _ ->
        list
    end
  end
end
