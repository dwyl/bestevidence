defmodule Bep.SearchController do
  use Bep.Web, :controller
  alias Bep.Tripdatabase.HTTPClient

  def create(conn, %{"search" => search}) do
    {:ok, data} = HTTPClient.search(search["search"])
    IO.inspect data
    render conn, "result.html"
  end
end