defmodule Bep.HistoryView do
  use Bep.Web, :view

  def format_date(date) do
    d = Date.from_iso8601!(date)
    Timex.format!(d, "{0D}-{0M}-{YYYY}")
  end
end
