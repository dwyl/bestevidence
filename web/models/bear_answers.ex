defmodule Bep.BearAnswers do
  use Bep.Web, :model
  alias Bep.{BearQuestions, Publication, PicoSearch}

  @moduledoc false

  schema "bear_answers" do
    belongs_to :bear_question, BearQuestions
    belongs_to :publication, Publication
    belongs_to :pico_search, PicoSearch
    field :index, :integer
    field :answer, :string
  end

  def paper_details_changeset(model, params \\ %{}) do
    model
    |> cast(params, [:answer])
  end
end
