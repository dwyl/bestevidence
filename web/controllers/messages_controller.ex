defmodule Bep.MessagesController do
  use Bep.Web, :controller
  alias Bep.{Messages, Type, User, UserMessagesRead}

  def view_messages(conn, %{"user" => to_user_id}) do
    current_user = conn.assigns.current_user
    to_user_id = get_user_id_to_msg(current_user, to_user_id)
    UserMessagesRead.update_user_msg_read(current_user)
    assigns = [
      messages: Messages.get_messages(to_user_id),
      to_user: to_user_id
    ]
    |> hide_nav_for_admin(conn)
    render(conn, :view, assigns)
  end

  def view_user_messages(conn, %{"msg_user_id" => user_id}) do
    user_type = Type.get_user_type(conn.assigns.current_user)
    users = Messages.get_user_list(conn.assigns.current_user, user_type)
    user_id_list = Enum.map(users, &(&1.id))
    parsed_user_id =
      case Integer.parse(user_id) do
        :error -> :error
        {id, _} -> id
      end
    cond do
      parsed_user_id == :error ->
        assigns = [hide_navbar: true, users: users]
        render(conn, :list_users, assigns)
      !Enum.member?(user_id_list, parsed_user_id) ->
        assigns = [hide_navbar: true, users: users]
        render(conn, :list_users, assigns)
      true ->
        path =
          case user_type == "client-admin" do
            true ->
              &messages_path/3
            _ ->
              &sa_messages_path/3
          end
        redirect(conn, to: path.(conn, :view_messages, %{user: user_id}))
    end
  end

  def list_users(conn, _params) do
    user_type = Type.get_user_type(conn.assigns.current_user)
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
          {:ok, message} ->
            UserMessagesRead.update_user_msg_received(message)
            user_type = Type.get_user_type(conn.assigns.current_user)
            path = get_path(user_type)
            redirect(conn, to: path.(conn, :message_sent, []))
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
  defp get_path(user_type) do
    case user_type do
      "super-admin" ->
        &sa_messages_path/3
      "client-admin" ->
        &ca_messages_path/3
    end
  end

  defp hide_nav_for_admin(list, conn) do
    user_type = Type.get_user_type(conn.assigns.current_user)
    is_user_sa_bool = user_type == "super-admin" || user_type == "client-admin"

    case is_user_sa_bool do
      true ->
        [{:hide_navbar, true} | list]
      _ ->
        list
    end
  end

  def get_user_id_to_msg(user, to_user_id) do
    user_type = Type.get_user_type(user)

    case user_type do
      "regular" ->
        user.id
      "client-admin" ->
        user_msg_belong_to = Repo.get!(User, to_user_id)

        if user_msg_belong_to.client_id == user.client_id do
          to_user_id
        else
          user.client_id
        end
      "super-admin" ->
        to_user_id
    end
  end
end
