defmodule Bep.PicoSearchController do
  use Bep.Web, :controller
  alias Bep.{PicoSearch, PicoOutcome}
  alias Ecto.Changeset

  def new(conn, %{"note_id" => note_id}) do
    changeset = PicoSearch.changeset(%PicoSearch{})
    assigns = [changeset: changeset, note_id: note_id]
    render(conn, "new.html", assigns)
  end

  def create(conn, %{"pico_search" => pico_search_params}) do
    pico_search_params = update_prob(pico_search_params)
    note_id = pico_search_params["note_id"]
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
        assigns = [changeset: changeset, note_id: note_id]
        render(conn, "new.html", assigns)
    end
  end

  # Helpers
  defp update_prob(params) do
    prob = params["probability"]
    if prob != "" do
      case String.contains?(prob, "%") do
        true ->
          [prob, _] = String.split(prob, "%")
          Map.put(params, "probability", prob)
        false ->
          params
      end
    else
      params
    end
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
