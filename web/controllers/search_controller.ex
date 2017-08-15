defmodule Bep.SearchController do
  use Bep.Web, :controller
  alias Bep.{Tripdatabase.HTTPClient, Search, NoteSearch, User}
  import Phoenix.View, only: [render_to_string: 3]

  def action(conn, _) do
    user = Map.get(conn.assigns, :current_user)
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, user])
  end

  defp user_searches(u) do
    User
    |> Repo.get!(u.id)
    |> Repo.preload(
      searches: from(s in Search, order_by: [desc: s.inserted_at], limit: 5)
    )
    |> Repo.preload(
      searches: :note_searches
    )
  end

  def index(conn, _, user) do
    searches = user_searches(user).searches
    |> IO.inspect
    render conn, "index.html", searches: searches
  end

  def create(conn, %{"search" => search_params}, user) do
    term = search_params["term"]

    case term do
      "" ->
        conn
        |> put_flash(:error, "Don't forget to search for some evidence!")
        |> redirect(to: search_path(conn, :index))
      _ ->
        {:ok, data} = HTTPClient.search(term)
        changeset =
          user
          |> build_assoc(:searches)
          |> Search.create_changeset(search_params, data["total"])
        case Repo.insert(changeset) do
          {:ok, search} ->
            conn
            |> render("results.html", search: term, data: data, id: search.id)
          {:error, _changeset} ->
            conn
            |> put_flash(:error, "Oops, something wrong happen, please try again.")
            |> render(search_path(conn, :index), changeset: changeset)
        end
    end
  end

  def load(conn, %{"page" => page, "term" => term, "searchId" => search_id}, _) do
    skip = String.to_integer(page) * 20
    {:ok, data} = HTTPClient.search(term, skip)
    html = render_to_string(
      Bep.SearchView,
      "load.html",
      data: data, start: skip + 1, id: search_id)
    conn
    |> put_status(200)
    |> json(%{data: html})
  end
end
