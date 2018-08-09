defmodule Bep.BearAnswers do
  use Bep.Web, :model
  alias Bep.{BearQuestion, PicoSearch, Publication, Repo}

  @moduledoc false

  schema "bear_answers" do
    belongs_to :bear_question, BearQuestion
    belongs_to :publication, Publication
    belongs_to :pico_search, PicoSearch
    field :index, :integer
    field :answer, :string
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:answer, :index])
  end

  # HELPERS
  def insert_ans(struct, q_and_a_map, pub, pico_search) do
    if q_and_a_map != nil do # if index is on map then add index
      {answer, bear_q_id, o_index} = q_and_a_map
      bear_question = Repo.get(BearQuestion, bear_q_id)

      struct
      |> changeset(%{answer: answer, index: o_index})
      |> put_assoc(:bear_question, bear_question)
      |> put_assoc(:publication, pub)
      |> put_assoc(:pico_search, pico_search)
      |> Repo.insert!()
    end
  end
end
