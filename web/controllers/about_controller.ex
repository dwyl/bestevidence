defmodule Bep.AboutController do
  use Bep.Web, :controller

  def index(conn, _params) do
      bg_colour = get_client_colour(conn, :login_page_bg_colour)

      render(conn, "index.html", bg_colour: bg_colour)
  end
end
