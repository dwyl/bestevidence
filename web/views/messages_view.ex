defmodule Bep.MessagesView do
  use Bep.Web, :view
  alias Plug.Conn
  alias Bep.Type

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

  def user_or_admin_classes(conn) do
    if conn.request_path =~ "super-admin" do
      "mt4 w-80 center"
    else
      "pt2 pt5-l mt4 w-80 center"
    end
  end

  def show_hide_user_id(conn, to_user) do
    user_type = Type.get_user_type(conn.assigns.current_user)

    if user_type != "regular" do
      content_tag(:p, "User #{to_user}", class: "tc")
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
