defmodule Bep.NotePublicationController do
  use Bep.Web, :controller
  alias Bep.{NotePublication, Publication}

  def new(conn, params) do
    publication = Repo.get!(Publication, params["publication_id"])
    changeset = NotePublication.changeset(%NotePublication{})
    render conn, "new.html", changeset: changeset, publication: publication
  end

  def create(conn, %{"note_publication" => note_params}) do
    changeset = NotePublication.changeset(%NotePublication{}, note_params)
    Repo.insert!(changeset)
    conn
    |> redirect(to: history_path(conn, :index))
  end

  def edit(conn, %{"id" => note_id, "publication_id" => publication_id}) do
    note = Repo.get!(NotePublication, note_id)
    publication = Repo.get!(Publication, publication_id)
    changeset = NotePublication.changeset(note)
    render conn, "edit.html", changeset: changeset, publication: publication
  end

  def update(conn, %{"id" => note_id, "note_publication" => note_params}) do
    note = Repo.get!(NotePublication, note_id)
    changeset = NotePublication.changeset(note, note_params)
    Repo.update!(changeset)
    conn
    |> redirect(to: history_path(conn, :index))
  end

end