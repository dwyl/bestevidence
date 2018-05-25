defmodule Bep.AboutController do
  use Bep.Web, :controller
  alias Bep.{Client, Repo}

  def index(conn, _params) do
    bg_colour = get_client_colour(conn, :login_page_bg_colour)
    about_text =
      if Map.has_key?(conn.assigns, :client) do
        Map.get(conn.assigns.client, :about_text)
      else
        Client
        |> Repo.get_by(name: "default")
        |> Map.get(:about_text)
      end

    logo_url =
      if Map.has_key?(conn.assigns, :client) do
        Map.get(conn.assigns.client, :logo_url)
      else
        "default"
      end

    render(
      conn,
      "index.html",
      about_text: about_text,
      logo_url: logo_url,
      bg_colour: bg_colour
    )
  end
end
