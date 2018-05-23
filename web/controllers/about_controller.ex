defmodule Bep.AboutController do
  use Bep.Web, :controller
  alias Bep.{Client, Repo}

  def index(conn, _params) do
    about_text =
      if Map.has_key?(conn.assigns, :client) do
        Map.get(conn.assigns.client, :about_text)
      else
        Client
        |> Repo.get_by(name: "default")
        |> Map.get(:about_text)
      end

    render(conn, "index.html", about_text: about_text)
  end
end
