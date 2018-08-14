alias Bep.{BearQuestions, Repo}

question = fn(section, question) ->
  %BearQuestions{section: section, question: question}
end

paper_details_questions = %{
  section: "paper_details",
  questions: [
    "Why did you choose this paper?"
  ]
}

check_validity_questions = %{
  section: "check_validity",
  questions: BearQuestions.check_validity_questions()
}

calculate_results_questions = %{
  section: "calculate_results",
  questions: BearQuestions.calculate_results_questions()
}

relevance_questions = %{
  section: "relevance",
  questions: BearQuestions.relevance_questions()
}

insert_questions = fn(list) ->
  list
  |> Enum.map(fn(map) ->
    Enum.map(map.questions, &Repo.insert!(question.(map.section, &1), on_conflict: :nothing))
  end)
end

q_maps = [
  paper_details_questions,
  check_validity_questions,
  calculate_results_questions,
  relevance_questions
]

insert_questions.(q_maps)
