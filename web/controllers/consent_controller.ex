defmodule Bep.ConsentController do
  use Bep.Web, :controller

  def index(conn, _) do
    if conn.assigns.current_user do
      redirect(conn, to: search_path(conn, :index))
    else
      bg_colour = get_client_colour(conn, :login_page_bg_colour)
      btn_colour = get_client_colour(conn, :btn_colour)

      render(
        conn,
        "index.html",
        bg_colour: bg_colour,
        btn_colour: btn_colour
      )
    end
  end
end
