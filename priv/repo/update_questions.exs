alias Bep.{BearQuestion, Repo}
alias Ecto.Changeset
import Ecto.Query

q_maps = [
  BearQuestion.paper_details_questions,
  BearQuestion.check_validity_questions,
  BearQuestion.calculate_results_questions,
  BearQuestion.relevance_questions
]

update_questions = fn(list) ->
  list
  |> Enum.map(fn(map) ->
    query =
      from bq in BearQuestion,
      where: bq.section == ^map.section,
      order_by: [asc: bq.id]

    db_qs = Repo.all(query)

    0..(length(map.questions) -1)
    |> Enum.map(fn(i) ->
      db_q = Enum.at(db_qs, i)
      question = Enum.at(map.questions, i)
      if question !== db_q.question do
        db_q
        |> Changeset.change(question: question)
        |> Repo.update!()
      end
    end)
  end)
end

update_questions.(q_maps)
