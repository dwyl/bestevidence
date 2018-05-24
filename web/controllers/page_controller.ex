defmodule Bep.PageController do
  use Bep.Web, :controller

  def index(conn, _params) do
    if conn.assigns.current_user do
      redirect(conn, to: search_path(conn, :index))
    else
      bg_colour = get_client_colour(conn, :login_page_bg_colour)
      render(conn, "index.html", bg_colour: bg_colour)
    end
  end
end
