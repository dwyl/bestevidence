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
  def has_note_publications?(search) do
    if Enum.empty?(search.publications) do
      false
    else
      Enum.reduce(search.publications, false, fn(p, acc) ->
        acc || !Enum.empty?(p.note_publications)
      end)
    end
  end
end
