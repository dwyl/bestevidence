defmodule Bep.MessagesView do
  use Bep.Web, :view
  alias Bep.Type

  def ca_or_sa(conn, ca_var, sa_var) do
    user_type = Type.get_user_type(conn.assigns.current_user)
    case user_type do
      "client-admin" ->
        ca_var
      _ ->
        sa_var
    end
  end

  def reg_or_admin(conn, reg_var, admin_var) do
    user_type = Type.get_user_type(conn.assigns.current_user)
    case user_type do
      "regular" ->
        reg_var
      _ ->
        admin_var
    end
  end

  def message_to(conn, to_user) do
    bool =
      if Map.has_key?(conn.assigns, :to_all) do
        conn.assigns
        |> Map.get(:to_all)
        |> String.to_existing_atom()
      end

    case bool do
      true ->
        "all users"
      _ ->
        "User #{to_user}"
    end
  end

  def get_path(conn) do
    user_type = Type.get_user_type(conn.assigns.current_user)
    case user_type do
      "super-admin" ->
        &sa_messages_path/3
      "client-admin" ->
        &ca_messages_path/3
    end
  end

  def msg_path_helper(f1, f2, conn, action, params \\ []) do
    user_type = Type.get_user_type(conn.assigns.current_user)

    if user_type == "super-admin" do
      f1.(conn, action, params)
    else
      f2.(conn, action, params)
    end
  end

  def is_user_admin?(conn) do
    user_type = Type.get_user_type(conn.assigns.current_user)
    if user_type == "regular" do
      false
    else
      true
    end
  end
end
