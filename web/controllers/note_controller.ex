defmodule Bep.NoteController do
  use Bep.Web, :controller
  alias Bep.{User, Search, Publication, PicoSearch}

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
      |> Enum.filter(fn({_date, searches}) ->
        Enum.any?(searches, &(&1.publications !== []))
      end)
      |> Enum.map(fn({date, searches}) ->
        searches = Enum.filter(searches, &(&1.publications !== []))
        {date, searches}
      end)
      |> Enum.map(fn({date, searches}) ->
        searches = Enum.map(searches, fn(search) ->
          note_search = search.note_searches
          pico_search = Repo.get_by(PicoSearch, note_search_id: note_search.id)
          note_search = Map.put(note_search, :pico_search_id, pico_search.id)

          Map.put(search, :note_searches, note_search)
        end)
        {date, searches}
      end)

    render(conn, "index.html", searches: searches)
  end
end
