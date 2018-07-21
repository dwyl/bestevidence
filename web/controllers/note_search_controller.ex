defmodule Bep.NoteSearchController do
  use Bep.Web, :controller
  alias Bep.{NoteSearch, Search}

  def new(conn, params) do
    search = Repo.get!(Search, params["search_id"])
    changeset = NoteSearch.changeset(%NoteSearch{})
    assigns = [
      changeset: changeset,
      search: search,
      btn_colour: get_client_colour(conn, :btn_colour)
    ]
    render(conn, "new.html", assigns)
  end

  # starting a pico
  def create(conn, %{"note_search" => note_params, "start_pico" => "true"}) do
    changeset = NoteSearch.changeset(%NoteSearch{}, note_params)
    note = Repo.insert!(changeset)
    redirect(conn, to: pico_search_path(conn, :new, note_id: note.id))
  end

  # this will become where the save and continue later btn will go
  def create(conn, %{"note_search" => note_params}) do
    changeset = NoteSearch.changeset(%NoteSearch{}, note_params)
    Repo.insert!(changeset)
    redirect(conn, to: history_path(conn, :index))
  end

  def edit(conn, %{"id" => note_id, "search_id" => search_id}) do
    note = Repo.get!(NoteSearch, note_id)
    search = Repo.get!(Search, search_id)
    changeset = NoteSearch.changeset(note)
    body_email = if note.note, do: note.note, else: ""
    mailto = """
      mailto:?subject=BestEvidence: Note about "#{search.term}"&body=#{URI.encode(body_email)}
    """
    btn_colour = get_client_colour(conn, :btn_colour)

    render(
      conn,
      "edit.html",
      changeset: changeset,
      search: search,
      mailto: mailto,
      btn_colour: btn_colour
    )
  end

  def update(conn, %{"id" => note_id, "note_search" => note_params}) do
    note = Repo.get!(NoteSearch, note_id)
    changeset = NoteSearch.changeset(note, note_params)
    Repo.update!(changeset)
    conn
    |> redirect(to: history_path(conn, :index))
  end
end
