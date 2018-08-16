defmodule Bep.BearQuestion do
  use Bep.Web, :model
  alias Bep.{BearAnswers, BearQuestion, Repo}
  alias Ecto.Query

  @moduledoc false

  schema "bear_questions" do
    field :section, :string
    field :question, :string
    has_many :bear_answers, BearAnswers
  end

  def all_questions_for_sec(pub_id, section) do
    q =
      from bq in BearQuestion,
      where: bq.section == ^section,
      order_by: [asc: bq.id]

    q
    |> Repo.all()
    |> Enum.map(fn(bq) ->
      bq_ans_query =
        from ba in BearAnswers,
        where: ba.bear_question_id == ^bq.id and ba.publication_id == ^pub_id

      bq_ans_query = Query.last(bq_ans_query)
      ba = Repo.one(bq_ans_query)

      case ba do
        nil ->
          Map.put(bq, :answer, "")
        _ ->
          Map.put(bq, :answer, ba.answer)
      end
    end)
  end

  def check_validity_questions do
    [
      "Did the trial address a clearly focused issue?",
      "Was the assignment of patients to treatments randomized?",
      "Were all of the patients who entered the trial properly accounted for at its conclusion?",
      "Were patients, health workers and study personnel 'blind' to treatment?",
      "Were the groups similar at the start of the trial?",
      "Aside from the experimental intervention, were the groups treated equally?",
      "In light of the above assessment, what is the risk of bias for each outcome?",
      "Any further comments?"
    ]
  end

  def calculate_results_questions do
    [
      "intervention_yes",
      "intervention_no",
      "control_yes",
      "control_no",
      "Notes"
    ]
  end

  def relevance_questions do
    [
      "Can the results be applied to your patient or local population?",
      "Were all clinically important outcomes considered?",
      "Are the benefits worth the harms and costs?",
      "Posterior probability",
      "Any further comments?",
      "Date started",
      "Date completed",
      "Expiry date (default 3 years)"
    ]
  end
end
