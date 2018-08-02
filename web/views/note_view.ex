defmodule Bep.NoteView do
  use Bep.Web, :view
  defdelegate format_date(date), to: Bep.HistoryView, as: :format_date
end
