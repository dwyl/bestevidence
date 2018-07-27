defmodule Bep.PicoSearchController do
  use Bep.Web, :controller
  alias Bep.{PicoSearch, PicoOutcome, Search}
  alias Ecto.Changeset

  def new(conn, %{"note_id" => note_id, "search_id" => search_id}) do
    search = Repo.get(Search, search_id)
    changeset = PicoSearch.changeset(%PicoSearch{})
    assigns = [changeset: changeset, note_id: note_id, search: search]
    render(conn, "new.html", assigns)
  end

  # use pico search
  def create(conn, %{"pico_search" => pico_search_params, "search_trip" => "true"}) do
    pico_search_params = update_prob(pico_search_params)
    note_id = pico_search_params["note_id"]
    search_id = pico_search_params["search_id"]
    pico_outcomes = get_pico_outcomes(pico_search_params)
    note_search = Repo.get(Bep.NoteSearch, note_id)
    changeset =
      %PicoSearch{}
      |> PicoSearch.changeset(pico_search_params)
      |> Changeset.put_assoc(:note_search, note_search)

    case Repo.insert(changeset) do
      {:ok, pico_search} ->
        Enum.map(pico_outcomes, fn(outcome) ->
          %PicoOutcome{}
          |> PicoOutcome.changeset(outcome)
          |> Changeset.put_assoc(:pico_search, pico_search)
          |> Repo.insert!()
        end)

        # make api call with the search term render the Search results.html
        search = Repo.get(Search, search_id)
        user = conn.assigns.current_user
        search_data = Search.search_data_for_create(%{"term" => search.term}, user)
        search =
          search
          |> Changeset.change(number_results: search_data.data["total"])
          |> Repo.update!(force: true)

        assigns =
          [
            search: search.term,
            data: search_data.data,
            id: search.id,
            bg_colour: get_client_colour(conn, :login_page_bg_colour),
            search_bar_colour: get_client_colour(conn, :search_bar_colour)
          ]
        render(conn, Bep.SearchView, "results.html", assigns)
      {:error, changeset} ->
        search = Repo.get(Search, search_id)
        assigns = [changeset: changeset, note_id: note_id, search: search]
        render(conn, "new.html", assigns)
    end
  end

  # save and continue later
  def create(conn, %{"pico_search" => pico_search_params}) do
    pico_search_params = update_prob(pico_search_params)
    note_id = pico_search_params["note_id"]
    search_id = pico_search_params["search_id"]
    pico_outcomes = get_pico_outcomes(pico_search_params)
    note_search = Repo.get(Bep.NoteSearch, note_id)
    changeset =
      %PicoSearch{}
      |> PicoSearch.changeset(pico_search_params)
      |> Changeset.put_assoc(:note_search, note_search)

    case Repo.insert(changeset) do
      {:ok, pico_search} ->
        Enum.map(pico_outcomes, fn(outcome) ->
          %PicoOutcome{}
          |> PicoOutcome.changeset(outcome)
          |> Changeset.put_assoc(:pico_search, pico_search)
          |> Repo.insert!()
        end)
        redirect(conn, to: search_path(conn, :index))
      {:error, changeset} ->
        search = Repo.get(Search, search_id)
        assigns = [changeset: changeset, note_id: note_id, search: search]
        render(conn, "new.html", assigns)
    end
  end

  # the edit route also needs to preload
  # the pico_outcome data related to this pico_search
  def edit(conn, %{"id" => pico_search_id, "note_id" => note_id, "search_id" => search_id}) do
    pico_search = Repo.get(PicoSearch, pico_search_id)
    search = Repo.get(Search, search_id)
    changeset = PicoSearch.changeset(pico_search)
    assigns = [changeset: changeset, note_id: note_id, search: search]
    render(conn, "new.html", assigns)
  end

  # Helpers
  defp update_prob(params) do
    prob = params["probability"]
    prob = Regex.replace(~r/\D/, prob, "")
    Map.put(params, "probability", prob)
  end

  defp get_pico_outcomes(pico_search) do
    pico_search
    |> Map.keys()
    |> Enum.filter(&(&1 =~ "outcome_input"))
    |> Enum.reduce([], fn(key, acc) ->
      value = Map.get(pico_search, key)
      case value == "" do
        true -> acc
        false ->
          [_ , index] = String.split(key, "outcome_input")
          pico_outcome = %{
            o: Map.get(pico_search, "outcome_input#{index}"),
            o_index: Map.get(pico_search, "outcome_index#{index}"),
            benefit: Map.get(pico_search, "outcome_benefit#{index}")
          }
          [pico_outcome | acc]
      end
    end)
  end
end
