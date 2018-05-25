defmodule Bep.AboutController do
  use Bep.Web, :controller
  alias Bep.{Client, Repo}

  def index(conn, _params) do
    bg_colour = get_client_colour(conn, :login_page_bg_colour)
    about_text = conn.assigns.client.about_text
    logo_url = conn.assigns.client.logo_url

    render(
      conn,
      "index.html",
      about_text: about_text,
      logo_url: logo_url,
      bg_colour: bg_colour
    )
  end
end
