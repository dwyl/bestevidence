defmodule Bep.AboutController do
  use Bep.Web, :controller

  def index(conn, _params) do
      header_colour = get_client_colour(conn, :search_bar_colour)

      render(conn, "index.html", header_colour: header_colour)
  end
end
