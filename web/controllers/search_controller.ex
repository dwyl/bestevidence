defmodule Bep.SearchController do
  use Bep.Web, :controller
  alias Bep.{
    Tripdatabase.HTTPClient,
    Search,
    User,
    Publication,
    NotePublication
  }
  alias Ecto.Changeset

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
    btn_colour = get_client_colour(conn, :btn_colour)

    render(
      conn,
      "index.html",
      searches: searches,
      btn_colour: btn_colour
    )
  end

  def create(conn, %{"search" => search_params}, user) do
    term = search_params["term"]
    bg_colour = get_client_colour(conn, :login_page_bg_colour)
    search_bar_colour = get_client_colour(conn, :search_bar_colour)

    case term do
      "" ->
        conn
        |> put_flash(:error, "Don't forget to search for some evidence!")
        |> redirect(to: search_path(conn, :index))
      _ ->

        data = case HTTPClient.search(term) do
          {:error, _} ->
            %{"total" => 0, "documents" => []}
          {:ok, res} ->
            res
        end

        tripdatabase_ids = Enum.map(data["documents"], &(&1["id"]))
        pubs = get_publications(user, tripdatabase_ids)
        data = link_publication_notes(data, pubs)

        trimmed_term = term |> String.trim |> String.downcase

        case Repo.get_by(Search, term: trimmed_term, user_id: user.id) do
          nil ->
            changeset =
              user
              |> build_assoc(:searches)
              |> Search.create_changeset(search_params, data["total"])
            case Repo.insert(changeset) do
              {:ok, search} ->
                conn
                |> render(
                  "results.html",
                  search: search.term,
                  data: data,
                  id: search.id,
                  search_changeset: changeset,
                  bg_colour: bg_colour,
                  search_bar_colour: search_bar_colour
                )
              {:error, changeset} ->
                conn
                |> put_flash(:error, "Oops, something wrong happen, please try again.")
                |> render(search_path(conn, :index), changeset: changeset)
            end
            search ->
              search = Changeset.change search, number_results: data["total"]
              case Repo.update(search, force: true) do
                {:ok, search} ->
                  conn
                  |> render(
                    "results.html",
                    search: search.term,
                    data: data,
                    id: search.id,
                    search_changeset: search,
                    bg_colour: bg_colour,
                    search_bar_colour: search_bar_colour
                  )
                {:error, changeset} ->
                  conn
                  |> put_flash(:error, "Oops, something wrong happen, please try again.")
                  |> render(search_path(conn, :index), changeset: changeset)
              end
        end
    end
  end

  def filter(conn, %{"search" => search_params}, user) do
    term = search_params["term"]
    id = search_params["search_id"]

    data = case HTTPClient.search(term, search_params) do
      {:error, _} ->
        %{"total" => 0, "documents" => []}
      {:ok, res} ->
        res
    end
    tripdatabase_ids = Enum.map(data["documents"], &(&1["id"]))
    pubs = get_publications(user, tripdatabase_ids)
    data = link_publication_notes(data, pubs)
    bg_colour = get_client_colour(conn, :login_page_bg_colour)
    search_bar_colour = get_client_colour(conn, :search_bar_colour)

    render(
      conn,
      "results.html",
      search: term,
      data: data,
      id: id,
      bg_colour: bg_colour,
      search_bar_colour: search_bar_colour
    )
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
