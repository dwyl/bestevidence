defmodule Bep.NoteView do
  use Bep.Web, :view

  @doc"""
    iex>format_date("2016-08-08")
    "08-08-2016"
    iex>format_date(Timex.format!(Timex.today, "{YYYY}-{0M}-{0D}"))
    "Today"
  """
  def format_date(date) do
    d = Date.from_iso8601!(date)
    today = Timex.today
    yesterday = Timex.shift(today, days: -1)
    cond do
      today == d -> "Today"
      yesterday == d -> "Yesterday"
      true -> Timex.format!(d, "{0D}-{0M}-{YYYY}")
    end
  end
end
