defmodule Bep.SearchController do
  use Bep.Web, :controller
  alias Bep.Tripdatabase.HTTPClient

  def index(conn, _) do
    render conn, "index.html"
  end

  def new(conn, _) do
    search = conn.query_params["search"]["search"]
    case search do
      "" ->
        conn
        |> put_flash(:error, "Don't forget to search for some evidences!")
        |> redirect(to: search_path(conn, :index))
      _ ->
        {:ok, data} = HTTPClient.search(search)
        conn
        |> render("results.html", search: search, data: data)
    end
  end
end
