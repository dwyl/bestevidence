defmodule Bep.PicoSearchView do
  use Bep.Web, :view

  def render_outcomes(f, outcomes) do
    Enum.map(1..9, &render("outcome.html", [
      f: f,
      i: &1,
      outcome: Enum.at(outcomes, &1 - 1, %{o: ""})
    ]))
  end

  def outcome_index(str, i) do
    "outcome_#{str}_#{i}"
  end

  def create_atom(str, i) do
    String.to_atom("#{str}_#{i}")
  end
end
