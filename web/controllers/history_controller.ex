defmodule Bep.HistoryController do
  use Bep.Web, :controller
  alias Bep.{Search, NoteController}

  def index(conn, _) do
    user = conn.assigns.current_user
    searches =
      NoteController.get_all_notes(user).searches
      |> Search.group_searches_by_day()
    render conn, "index.html", searches: searches
  end
end
