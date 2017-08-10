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
        render conn, "new.html", changeset: changeset, search: search
    end
    conn
    |> redirect(to: history_path(conn, :index))
  end

  def edit(conn, %{"id" => note_id, "search_id" => search_id}) do
    note = Repo.get!(NoteSearch, note_id)
    search = Repo.get!(Search, search_id)
    changeset = NoteSearch.changeset(note)
    render conn, "edit.html", changeset: changeset, search: search
  end

  def update(conn, %{"id" => note_id, "note_search" => note_params}) do
    note = Repo.get!(NoteSearch, note_id)
    changeset = NoteSearch.changeset(note, note_params)

    case Repo.update(changeset) do
      {:ok, note} ->
        conn
        |> redirect(to: history_path(conn, :index))
      {:error, changeset} ->
        search = Repo.get!(Search, note_params["search_id"])
        render conn, "edit.html", changeset: changeset, search: search
    end
  end
end
