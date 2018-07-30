defmodule Bep.PicoSearchController do
  use Bep.Web, :controller
  alias Bep.{NoteSearch, PicoSearch, PicoOutcome, Search}
  alias Ecto.Changeset

  def new(conn, %{"note_id" => note_id, "search_id" => search_id}) do
    search = Repo.get(Search, search_id)
    changeset = PicoSearch.changeset(%PicoSearch{})
    assigns = [changeset: changeset, note_id: note_id, search: search]
    render(conn, "new.html", assigns)
  end

  def create(conn, %{"pico_search" => pico_search_params} = params) do
    pico_search_params = update_prob(pico_search_params)
    note_id = pico_search_params["note_id"]
    search_id = pico_search_params["search_id"]
    search = Repo.get(Search, search_id)
    pico_outcomes = get_pico_outcomes(pico_search_params)
    note_search = Repo.get(NoteSearch, note_id)
    changeset =
      %PicoSearch{}
      |> PicoSearch.changeset(pico_search_params)
      |> Changeset.put_assoc(:note_search, note_search)

    case Repo.insert(changeset) do
      {:ok, pico_search} ->
        Enum.map(pico_outcomes, fn(outcome) ->
          # MAKE THIS AN ISSUE
          # Not blocker but something to look into
          # I should only insert new outcomes or outcomes that have been updated
          # Could add an extra frild to the outcome map which can say if it is
          # a new outcome to be inserted or not e.g. outcome_new_bool: true
          %PicoOutcome{}
          |> PicoOutcome.changeset(outcome)
          |> Changeset.put_assoc(:pico_search, pico_search)
          |> Repo.insert!()
        end)

        case Map.get(params, "search_trip") do
          # Save and continue later route
          nil ->
            redirect(conn, to: search_path(conn, :index))

          # make api call with the search term render the Search results.html
          # this will become the pico search route but reg search for now
          "true" ->
            user = conn.assigns.current_user
            search_data =
              %{"term" => search.term}
              |> Search.search_data_for_create(user)

            search =
              search
              |> Changeset.change(number_results: search_data.data["total"])
              |> Repo.update!(force: true)

            assigns =
              [
                search: search,
                data: search_data.data,
                bg_colour: get_client_colour(conn, :login_page_bg_colour),
                search_bar_colour: get_client_colour(conn, :search_bar_colour)
              ]
            render(conn, Bep.SearchView, "results.html", assigns)
        end

      # not sure if this case is needed. Awaiting question to be answered on
      # gh https://git.io/fNzTD
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
