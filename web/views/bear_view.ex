defmodule Bep.BearView do
  use Bep.Web, :view
  defdelegate format_date(date), to: Bep.HistoryView, as: :format_date

  def create_key(questions, i, outcome) do
    case questions do
      [] ->
        :ignore
      _ ->
        q_id = Enum.at(questions, i)

        :"q_#{q_id}_o_index_#{outcome.o_index}"
    end
  end

  def ans_to_date(date_str) do
    if date_str == "" do
      three_years =
        Date.utc_today()
        |> Timex.shift(years: 3)

      %{day: three_years.day, month: three_years.month, year: three_years.year}
    else
      [d, m, y] = String.split(date_str, "/")

      %{day: d, month: m, year: y}
    end
  end

  def get_date_year_range do
    today = Date.utc_today()

    (today.year)..(today.year + 10)
  end

  def format_date_str(date_str) do
    [d, m, y] = String.split(date_str, "/")
    d = add_0_if_needed(d)
    m = add_0_if_needed(m)

    "#{y}-#{m}-#{d}"
  end

  defp add_0_if_needed(str) do
    if String.length(str) == 1 do
      "#{0}#{str}"
    else
      str
    end
  end
end
