defmodule Bep.HistoryController do
  use Bep.Web, :controller
  alias Bep.User

  defp get_history(u) do
    User
    |> where([user], user.id == ^u.id)
    |> join(:left, [user], searches in assoc(user, :searches))
    |> join(
      :left,
      [user, searches],
      publications in assoc(searches, :publications)
    )
    |> order_by(
      [user, searches, publications],
      [desc: searches.inserted_at, desc: publications.inserted_at]
    )
    |> preload(
      [user, searches, publications],
      [searches: {searches, publications: publications}]
    )
  end

  def index(conn, _) do
    user = conn.assigns.current_user
    history = case Repo.all(get_history(user)) do
      [h] -> h
      [] -> %{:searches => []}
    end
    searches = Enum.group_by(
      history.searches,
      fn(s) -> Date.to_string(s.inserted_at)
    end)
    render conn, "index.html", searches: searches
  end
end
