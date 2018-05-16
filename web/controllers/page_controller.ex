defmodule Bep.PageController do
  use Bep.Web, :controller

  def index(conn, _params) do
    if conn.assigns.current_user do
      redirect(conn, to: search_path(conn, :index))
    else
      if Map.has_key?(conn.assigns, :client) do 
        bg_colour = conn.assigns.client.login_page_bg_colour
        render(conn, "index.html", bg_colour: bg_colour)
      else 
        default_colour = "#8f182e"
        render(conn, "index.html", bg_colour: default_colour)
      end
    end
  end
end
