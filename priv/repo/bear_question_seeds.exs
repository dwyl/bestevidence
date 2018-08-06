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

check_validity_questions = %{
  section: "check_validity",
  questions: [
    "Did the trial address a clearly focused issue?",
    "Was the assignment of patients to treatments randomised?",
    "Were all of the patients who entered the trial properly accounted for at its conclusion?",
    "Were patients, health workers and study personnel 'blind' to treatment?",
    "Were the groups similar at the start of the trial?",
    "Aside from the experimental intervention, were the groups treated equally?",
    "In light of the above assessment, what is the risk of bias for each outcome?",
    "Any further comments?"
  ]
}

calculate_results_questions = %{
  section: "calculate_results",
  questions: [
    "control_yes",
    "control_no",
    "intervention_yes",
    "intervention_no",
    "Notes",
    "ARR",
    "RR",
    "RRR",
    "OR",
    "NNT"
  ]
}

insert_questions = fn(list) ->
  list
  |> Enum.map(fn(map) ->
    Enum.map(map.questions, &Repo.insert!(question.(map.section, &1), on_conflict: :nothing))
  end)
end

q_lists = [
  paper_details_questions,
  check_validity_questions,
  calculate_results_questions
]

insert_questions.(q_lists)
