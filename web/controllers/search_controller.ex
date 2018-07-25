defmodule Bep.SearchController do
  use Bep.Web, :controller
  alias Bep.{
    Tripdatabase.HTTPClient,
    Search,
    User,
    Publication,
    NotePublication,
    NoteSearch
  }
  alias Ecto.{Changeset, Query}

  def index(conn, _, user) do
    searches = user_searches(user).searches
    btn_colour = get_client_colour(conn, :btn_colour)
    assigns = [searches: searches, btn_colour: btn_colour]
    render(conn, "index.html", assigns)
  end

  # If user clicks search without putting anything into the search box
  def create(conn, %{"search" => %{"term" => ""}}, _user) do
    redirect(conn, to: search_path(conn, :index))
  end

  # To create an uncertainty
  def create(conn, %{"question_type" => "uncertainty", "search" => search_params}, user) do
    term = search_params["term"]
    trimmed_term = term |> String.trim() |> String.downcase()

    case Repo.get_by(Search, term: trimmed_term, user_id: user.id) do
      nil ->
        changeset =
          user
          |> build_assoc(:searches)
          |> Search.changeset(search_params)
          |> Changeset.put_change(:uncertainty, true)

        # does this need to be a case statement with Repo.insert {:ok, _} etc
        search = Repo.insert!(changeset)
        path = note_search_path(conn, :new, search_id: search.id)
        redirect(conn, to: path)
      search ->
        query = from(ns in NoteSearch, where: ns.search_id == ^search.id)
        last_query = Query.last(query)

        case Repo.one(last_query) do
          nil ->
            path = note_search_path(conn, :new, search_id: search.id)
            redirect(conn, to: path)
          note ->
            path = note_search_path(conn, :edit, note, search_id: search.id)
            redirect(conn, to: path)
        end
    end
  end

  # Create a regular search
  def create(conn, %{"search" => search_params}, user) do
    search_data = search_data_for_create(search_params, user)
    u_id = user.id

    case Repo.get_by(Search, term: search_data.trimmed_term, user_id: u_id) do
      nil ->
        changeset =
          user
          |> build_assoc(:searches)
          |> Search.create_changeset(search_params, search_data.data["total"])

        search = Repo.insert!(changeset)
        assigns = get_create_assign(conn, search, search_data.data, changeset)
        render(conn, "results.html", assigns)
      search ->
        search =
          search
          |> Changeset.change(number_results: search_data.data["total"])
          |> Repo.update!(force: true)
        assigns = get_create_assign(conn, search, search_data.data)
        render(conn, "results.html", assigns)
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
    assigns = [
      search: term,
      data: data,
      id: id,
      bg_colour: bg_colour,
      search_bar_colour: search_bar_colour
    ]

    render(conn, "results.html", assigns)
  end

  # helpers
  def action(conn, _) do
    user = Map.get(conn.assigns, :current_user)
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, user])
  end

  defp user_searches(u) do
    query = from(s in Search, order_by: [desc: s.inserted_at], limit: 6)
    User
    |> Repo.get!(u.id)
    |> Repo.preload(searches: query)
    |> Repo.preload(searches: :note_searches)
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

  defp get_create_assign(conn, search, data, changeset \\ nil) do
    bg_colour = get_client_colour(conn, :login_page_bg_colour)
    search_bar_colour = get_client_colour(conn, :search_bar_colour)
    search_changeset =
      case changeset == nil do
        true -> changeset
        false -> search
      end

    [
      search: search.term,
      data: data,
      id: search.id,
      search_changeset: search_changeset,
      bg_colour: bg_colour,
      search_bar_colour: search_bar_colour
    ]
  end

  defp search_data_for_create(search_params, user) do
    term = search_params["term"]
    data =
      case HTTPClient.search(term) do
        {:error, _} ->
          %{"total" => 0, "documents" => []}
        {:ok, res} ->
          res
      end

    tripdatabase_ids = Enum.map(data["documents"], &(&1["id"]))
    pubs = get_publications(user, tripdatabase_ids)
    data = link_publication_notes(data, pubs)
    trimmed_term = term |> String.trim |> String.downcase

    %{
      term: term,
      trimmed_term: trimmed_term,
      data: data
    }
  end
end
