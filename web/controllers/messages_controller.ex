defmodule Bep.MessagesController do
  use Bep.Web, :controller
  alias Bep.{Messages, Type}

  def view_messages(conn, %{"user" => user_id}) do
    assigns = [
      messages: Messages.get_messages(user_id),
      to_user: user_id,
    ]
    |> hide_nav_for_SA(conn)
    render(conn, :view, assigns)
  end

  def list_users(conn, _params) do
    user_type = get_session(conn, :user_type)
    assigns = [
      hide_navbar: true,
      users: Messages.get_user_list(conn.assigns.current_user, user_type)
    ]
    render(conn, :list_users, assigns)
  end

  def new(conn, params) do
    to_assigns = Messages.create_to_params(params)
    assigns =
      [changeset: Messages.changeset(%Messages{}), hide_navbar: true]
      |> Enum.concat(to_assigns)

    render(conn, "new.html", assigns)
  end

  def create(conn, %{"message" => message}) do
    confirm_bool = String.to_existing_atom(message["confirm"])
    to_all_bool = String.to_existing_atom(message["to_all"])
    client_id = message["to_client"]
    return_to_message_bool = String.to_existing_atom(message["return_to_message"])
    message = Map.put(message, "from_id", conn.assigns.current_user.id)
    changeset = Messages.changeset(%Messages{}, message)

    cond do
      return_to_message_bool ->
        to_assigns = Messages.get_to_assigns(message)
        assigns =
          [changeset: changeset, hide_navbar: true]
          |> Enum.concat(to_assigns)
        render(conn, :new, assigns)
      (to_all_bool || client_id != "") && !confirm_bool ->
        to_assigns = Messages.get_to_assigns(message)
        assigns =
          [changeset: changeset, hide_navbar: true]
          |> Enum.concat(to_assigns)
        render(conn, :confirm, assigns)
      true ->
        case Repo.insert(changeset) do
          {:ok, _message} ->
            user_type = get_session(conn, :user_type)
            msg_sent_path = get_path(conn, user_type)
            redirect(conn, to: msg_sent_path)
          {:error, changeset} ->
            to_assigns = Messages.get_to_assigns(message)
            assigns =
              [changeset: changeset, hide_navbar: true]
              |> Enum.concat(to_assigns)
            render(conn, :new, assigns)
        end
    end
  end

  def message_sent(conn, _params) do
    assigns = [hide_navbar: true]
    render(conn, :message_sent, assigns)
  end

  #Helpers
  defp get_path(conn, user_type) do
    case user_type do
      "super-admin" ->
        sa_messages_path(conn, :message_sent)
      _ ->
        ca_messages_path(conn, :message_sent)
    end
  end

  defp hide_nav_for_SA(list, conn) do
    current_user_is_admin_bool =
      conn.assigns.current_user
      |> Repo.preload(:types)
      |> Map.get(:types)
      |> Type.is_type?("super-admin")

    case current_user_is_admin_bool do
      true ->
        [{:hide_navbar, current_user_is_admin_bool} | list]
      _ ->
        list
    end
  end
end
