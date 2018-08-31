alias Bep.{BearQuestion, Repo}

question = fn(section, question) ->
  %BearQuestion{section: section, question: question}
end

insert_questions = fn(list) ->
  list
  |> Enum.map(fn(map) ->
    Enum.map(map.questions, &Repo.insert!(question.(map.section, &1), on_conflict: :nothing))
  end)
end

q_maps = [
  BearQuestion.paper_details_questions,
  BearQuestion.check_validity_questions,
  BearQuestion.calculate_results_questions,
  BearQuestion.relevance_questions
]

insert_questions.(q_maps)
