defmodule Bep.MessagesView do
  use Bep.Web, :view

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
#   pt2 pt5-l mt4 w-80 center
# <%= if @conn.request_path =~ "super-admin" do %>
#   <%= component("admin_message_nav", [conn: @conn]) %>
# <% end %>
# <div class="pt2 pt5-l mt4 w-80 center">
end
