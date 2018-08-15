defmodule Bep.BearView do
  use Bep.Web, :view

  def create_key(questions, i, outcome) do
    q_id = Enum.at(questions, i)

    :"q_#{q_id}_o_index_#{outcome.o_index}"
  end

  def get_answer(answers, i) do
    Enum.at(answers, i)
  end
end
