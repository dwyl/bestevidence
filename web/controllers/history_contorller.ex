defmodule Bep.HistoryController do
  use Bep.Web, :controller
  alias Bep.{User, Search, Publication}

  defp get_history(u) do
    User
    |> Repo.get!(u.id)
    |> Repo.preload(
      searches: from(s in Search, order_by: [desc: s.inserted_at])
    )
    |> Repo.preload(
      searches: [
        publications: from(p in Publication, order_by: [desc: p.inserted_at])
      ]
    )
    |> Repo.preload(
      searches: :note_searches
    )
  end

  def index(conn, _) do
    user = conn.assigns.current_user
    searches = get_history(user).searches
    |> group_searches_by_day()
    render conn, "index.html", searches: searches
  end

  defp group_searches_by_day(searches) do
    searches
    |> Enum.group_by(
      fn(s) -> Date.to_string(s.inserted_at)
    end)
    |> Enum.sort(fn({k1, _}, {k2, _}) -> k1 >= k2 end)
  end
end
