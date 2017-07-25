defmodule Bep.SearchController do
  use Bep.Web, :controller
  alias Bep.{Tripdatabase.HTTPClient, Search}

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

  defp user_searches(user) do
    assoc(user, :searches)
  end

  def index(conn, _, user) do
    searches = Enum.take(Repo.all(user_searches(user)), 5)
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
end
