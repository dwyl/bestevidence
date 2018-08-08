defmodule Bep.BearQuestions do
  use Bep.Web, :model
  alias Bep.{BearAnswers, BearQuestions, Repo}
  import Ecto.Query

  @moduledoc false

  schema "bear_questions" do
    field :section, :string
    field :question, :string
    has_many :bear_answers, BearAnswers
  end

  # HELPERS
  def all_questions_for_sec(section) do
    Repo.all(
      from bq in BearQuestions,
      where: bq.section == ^section
    )
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
