defmodule Bep.ConsentController do
  use Bep.Web, :controller

  def index(conn, _) do
    if conn.assigns.current_user do
      redirect(conn, to: search_path(conn, :index))
    else
      header_colour = get_client_colour(conn, :search_bar_colour)
      btn_colour = get_client_colour(conn, :btn_colour)

      render(
        conn,
        "index.html",
        header_colour: header_colour,
        btn_colour: btn_colour
      )
    end
  end
end
