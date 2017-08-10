defmodule Bep.NoteSearchController do
  use Bep.Web, :controller
  alias Bep.{NoteSearch, Search}

  def new(conn, params) do
    search = Repo.get!(Search, params["search_id"])
    changeset = NoteSearch.changeset(%NoteSearch{})
    render conn, "new.html", changeset: changeset, search: search
  end

  def create(conn, %{"note_search" => note_params}) do
    changeset = NoteSearch.changeset(%NoteSearch{}, note_params)
    case Repo.insert(changeset) do
      {:ok, note} ->
        conn
        |> redirect(to: history_path(conn, :index))
      {:error, changeset} ->
        search = Repo.get!(Search, note_params["search_id"])
        render(conn, "new.html", changeset: changeset, search: search)
    end
    conn
    |> redirect(to: history_path(conn, :index))
  end
end
