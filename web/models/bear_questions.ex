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

  # HELPERS
  def all_questions_for_sec(section, pub_id) do
    ba_query =
      from ba in BearAnswers,
      join: bq in BearQuestion, on: ba.bear_question_id == bq.id,
      where: ba.publication_id == ^pub_id and bq.section == ^section

    ba_sub_query = Query.last(ba_query)
    bq_sub_query = from(bq in BearQuestion, where: bq.section == ^section)

    query =
      from bq in BearQuestion,
      join: s1 in subquery(bq_sub_query), on: s1.id == bq.id,
      full_join: s in subquery(ba_sub_query), on: s.bear_question_id == bq.id,
      select: %{
        id: bq.id,
        question: bq.question,
        answer: s.answer
      }

    Repo.all(query)
  end

  def check_validity_questions do
    [
      "Did the trial address a clearly focused issue?",
      "Was the assignment of patients to treatments randomised?",
      "Were all of the patients who entered the trial properly accounted for at its conclusion?",
      "Were patients, health workers and study personnel 'blind' to treatment?",
      "Were the groups similar at the start of the trial?",
      "Aside from the experimental intervention, were the groups treated equally?",
      "In light of the above assessment, what is the risk of bias for each outcome?",
      "Any further comments?"
    ]
  end

  def calculate_results do
    [
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
  end

  def relevance_questions do
    [
      "Can the results be applied to the local population, or in your context?",
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
