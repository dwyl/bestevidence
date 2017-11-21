defmodule Bep.NoteView do
  use Bep.Web, :view

  defdelegate format_date(date), to: Bep.HistoryView, as: :format_date

  @doc"""
    iex> s = %{publications: []}
    iex>has_note_publications?(s)
    false
    iex> s = %{publications: [%{note_publications: [%{note: "note"}]}]}
    iex>has_note_publications?(s)
    true
  """
  def has_note_publications?(%{publications: []}), do: false
  def has_note_publications?(%{publications: publications}),
    do: Enum.any? publications, &(&1.note_publications != [])
end
