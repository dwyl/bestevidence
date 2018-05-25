defmodule Bep.NotePublicationController do
  use Bep.Web, :controller
  alias Bep.{NotePublication, Publication}

  def new(conn, params) do
    publication = Repo.get!(Publication, params["publication_id"])
    changeset = NotePublication.changeset(%NotePublication{})
    btn_colour = get_client_colour(conn, :btn_colour)

    render(
      conn,
      "new.html",
      changeset: changeset,
      publication: publication,
      btn_colour: btn_colour
    )
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
    body_email = """
    link:
    #{publication.url}

    note:
    #{note.note}
    """
    mailto = """
    mailto:?subject=BestEvidence: Note about "#{publication.value}"
    &body=#{URI.encode(body_email)}
    """
    btn_colour = get_client_colour(conn, :btn_colour)

    render(
      conn,
      "edit.html",
      changeset: changeset,
      publication: publication,
      btn_colour: btn_colour,
      mailto: mailto
    )
  end

  def update(conn, %{"id" => note_id, "note_publication" => note_params}) do
    note = Repo.get!(NotePublication, note_id)
    changeset = NotePublication.changeset(note, note_params)
    Repo.update!(changeset)
    conn
    |> redirect(to: history_path(conn, :index))
  end
end
