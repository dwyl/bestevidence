defmodule Bep.SearchController do
  use Bep.Web, :controller
  alias Bep.{Tripdatabase.HTTPClient, Search, User, NoteSearch}
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
  def create(conn, %{"search_btn" => btn_value, "search" => search_params}, user) do
    term = search_params["term"]
    trimmed_term = term |> String.trim() |> String.downcase()

    case Repo.get_by(Search, term: trimmed_term, user_id: user.id) do
      nil ->
        search =
          user
          |> build_assoc(:searches)
          |> Search.changeset(search_params)
          |> Changeset.put_change(:uncertainty, true)
          |> Repo.insert!()

        path =
          case btn_value do
            "collect" ->
              search_path(conn, :index)
            "start_bear" ->
              note_search_path(conn, :new, search_id: search.id)
          end

        redirect(conn, to: path)

      search ->
        case btn_value do
          "collect" ->
            search
            |> Search.changeset(search_params)
            |> Changeset.put_change(:uncertainty, true)
            |> Repo.update!()

            redirect(conn, to: search_path(conn, :index))
          "start_bear" ->
            query = from(ns in NoteSearch, where: ns.search_id == ^search.id)
            last_query = Query.last(query)

            path =
              case Repo.one(last_query) do
                nil ->
                  note_search_path(conn, :new, search_id: search.id)
                note ->
                  note_search_path(conn, :edit, note, search_id: search.id)
              end
            redirect(conn, to: path)
        end
    end
  end

  # Create a regular search
  def create(conn, %{"search" => search_params}, user) do
    search_data = Search.search_data_for_create(search_params, user)
    u_id = user.id

    case Repo.get_by(Search, term: search_data.trimmed_term, user_id: u_id) do
      nil ->
        search =
          user
          |> build_assoc(:searches)
          |> Search.create_changeset(search_params, search_data.data["total"])
          |> Repo.insert!()

        assigns = get_create_assign(conn, search, search_data.data)
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
    search_id = search_params["search_id"]
    search = Repo.get(Search, search_id)

    data = case HTTPClient.search(term, search_params) do
      {:error, _} ->
        %{"total" => 0, "documents" => []}
      {:ok, res} ->
        res
    end

    tripdatabase_ids = Enum.map(data["documents"], &(&1["id"]))
    pubs = Search.get_publications(user, tripdatabase_ids)
    data = Search.link_publication_notes(data, pubs)
    bg_colour = get_client_colour(conn, :login_page_bg_colour)
    search_bar_colour = get_client_colour(conn, :search_bar_colour)
    assigns = [
      search: search,
      data: data,
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

  defp get_create_assign(conn, search, data) do
    bg_colour = get_client_colour(conn, :login_page_bg_colour)
    search_bar_colour = get_client_colour(conn, :search_bar_colour)
    [
      search: search,
      data: data,
      bg_colour: bg_colour,
      search_bar_colour: search_bar_colour
    ]
  end
end
