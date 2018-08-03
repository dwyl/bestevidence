alias Bep.{BearQuestions, Repo}
import Ecto.Query

question = fn(section, question) ->
  %BearQuestions{section: section, question: question}
end

paper_details_questions = %{
  section: "paper_details",
  questions: [
    "Why did you choose this paper?"
  ]
}

insert_questions = fn(map) ->
  map.questions
  |> Enum.map(&Repo.insert!(question.(map.section, &1), on_conflict: :nothing))
end

insert_questions.(paper_details_questions)
