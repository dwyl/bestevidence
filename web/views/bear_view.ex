defmodule Bep.BearView do
  use Bep.Web, :view

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
        |> shift_date_one_year()
        |> shift_date_one_year()
        |> shift_date_one_year()

      %{day: three_years.day, month: three_years.month, year: three_years.year}
    else
      [d, m, y] = String.split(date_str, "/")

      %{day: d, month: m, year: y}
    end
  end

  def shift_date_one_year(date) do
    if Date.leap_year?(date) do
      Date.add(date, 366)
    else
      Date.add(date, 365)
    end
  end

  def get_date_year_range do
    today = Date.utc_today()

    (today.year)..(today.year + 10)
  end
end
