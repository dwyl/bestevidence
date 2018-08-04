defmodule Bep.NoteController do
  use Bep.Web, :controller
  alias Bep.{User, Search, Publication}

  def get_all_notes(u) do
    User
    |> Repo.get!(u.id)
    |> Repo.preload(searches:
      from(s in Search,
      order_by: [desc: s.updated_at])
    )
    |> Repo.preload(
      searches: [
        publications: from(p in Publication, order_by: [desc: p.updated_at])
      ]
    )
    |> Repo.preload(searches: :note_searches)
  end

  def index(conn, _) do
    user = conn.assigns.current_user
    searches =
      get_all_notes(user).searches
      |> Search.group_searches_by_day()

    render(conn, "index.html", searches: searches)
  end
end
