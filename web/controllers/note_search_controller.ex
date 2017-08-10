defmodule Bep.NoteSearchController do
  use Bep.Web, :controller
  alias Bep.{Search}

  def edit(conn, params) do
    search = Repo.get!(Search, params["id"])
    render conn, "edit.html", search: search
  end

  def update(conn, params) do
    render conn, "edit.html", search: %{term: ""}
  end
end
