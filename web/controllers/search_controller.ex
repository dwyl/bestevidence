defmodule Bep.SearchController do
  use Bep.Web, :controller
  alias Bep.{
    Tripdatabase.HTTPClient,
    Search,
    User,
    Publication,
    NotePublication
  }

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

        tripdatabase_ids = Enum.map(data["documents"], &(&1["id"]))
        pubs = get_publications(user, tripdatabase_ids)
        data = link_publication_notes(data, pubs)
        changeset =
          user
          |> build_assoc(:searches)
          |> Search.create_changeset(search_params, data["total"])
        case Repo.insert(changeset) do
          {:ok, search} ->
            conn
            |> render(
              "results.html",
              search: changeset.changes.term,
              data: data,
              id: search.id,
              search_changeset: changeset
            )
          {:error, _changeset} ->
            conn
            |> put_flash(:error, "Oops, something wrong happen, please try again.")
            |> render(search_path(conn, :index), changeset: changeset)
        end
    end
  end

  def filter(conn, %{"search" => search_params}, user) do
    term = search_params["term"]
    id = search_params["search_id"]

    {:ok, data} = HTTPClient.search(term, search_params)
    tripdatabase_ids = Enum.map(data["documents"], &(&1["id"]))
    pubs = get_publications(user, tripdatabase_ids)
    data = link_publication_notes(data, pubs)
    conn
    |> render("results.html", search: term, data: data, id: id)
  end

  def get_publications(u, tripdatabase_ids) do
    user_note = from np in NotePublication, where: np.user_id == ^u.id
    publications = from p in Publication,
      where: p.tripdatabase_id in ^tripdatabase_ids,
      preload: [note_publications: ^user_note]
    Repo.all(publications)
  end

  def link_publication_notes(data, publications) do
    documents = Enum.map(data["documents"], fn(evidence) ->
      publication = Enum.find(
        publications,
        fn(p) -> p.tripdatabase_id == evidence["id"] end
      )
      note_publications = publication && publication.note_publications
      publication_id = publication && publication.id
      evidence
      |> Map.put(:note_publications, note_publications || [])
      |> Map.put(:publication_id, publication_id)
    end)
    Map.put(data, "documents", documents)
  end

end
