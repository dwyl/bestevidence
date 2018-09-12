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

  def table_row_helper(header_value, answer) do
    if header_value == answer do
      content_tag(:td, "x", style: "text-align: center; font-weight: bold;")
    else
      content_tag(:td, "", style: "text-align: center;")
    end
  end

  def get_results_calculation(row, column, list) do
    {intervention_list, control_list} =
      list
      |> Enum.map(&String.to_integer/1)
      |> Enum.split(2)

    func = pick_sum_func(column)

    case row do
      "intervention" ->
        content_tag(:td, "#{func.(intervention_list)}", style: "padding-left: 1rem; padding-right: 1rem;")
      "control" ->
        content_tag(:td, "#{func.(control_list)}", style: "padding-left: 1rem; padding-right: 1rem;")
    end
  end

  defp get_yes(list) do
    Enum.at(list, 0)
  end

  defp get_no(list) do
    Enum.at(list, 1)
  end

  defp get_total(list) do
    get_yes(list) + get_no(list)
  end

  defp get_risk(list) do
    get_yes(list) / get_total(list)
  end

  defp pick_sum_func(str) do
    case str do
      "yes" ->
        &get_yes/1

      "no" ->
        &get_no/1

      "total" ->
        &get_total/1

      "risk" ->
        &get_risk/1
    end
  end

  def helper(map, type, str) do
    key =
      "#{type}_#{str}"
      |> String.to_atom()

    Map.get(map, key)
  end
end
