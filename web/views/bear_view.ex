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
end
