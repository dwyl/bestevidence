defmodule Bep.PicoSearchController do
  use Bep.Web, :controller
  alias Bep.{PicoSearch}

  def new(conn, %{"note_id" => note_id}) do
    changeset = PicoSearch.changeset(%PicoSearch{})
    assigns = [changeset: changeset, note_id: note_id]
    render(conn, "new.html", assigns)
  end

  def create(conn, params) do
    changeset = PicoSearch.changeset(%PicoSearch{})
    assigns = [changeset: changeset, note_id: 999]
    render(conn, "new.html", assigns)
  end
end
