defmodule Bep.PicoSearchView do
  use Bep.Web, :view

  def render_outcomes(f) do
    Enum.map(1..9, &render("outcome.html", [f: f, i: &1]))
  end

  def outcome_index(str, i) do
    "outcome#{i}"
  end

  def create_atom(str, i) do
    String.to_atom("#{str}_#{i}")
  end
end
