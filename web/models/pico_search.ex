defmodule Bep.PicoSearch do
  @moduledoc """
  PicoSearch model
  """
  use Bep.Web, :model
  alias Bep.{BearAnswers, NoteSearch, PicoOutcome, PicoSearch, Repo}

  schema "pico_searches" do
    belongs_to :note_search, NoteSearch
    field :p, :string
    field :i, :string
    field :c, :string
    field :position, :string
    field :probability, :integer
    has_many :pico_outcome, PicoOutcome
    has_many :bear_answers, BearAnswers
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    params_list = [:p, :i, :c, :position, :probability]

    struct
    |> cast(params, params_list)
  end

  # HELPERS
  def get_pico_search(search) do
    if search.uncertainty do
      query =
        from ps in PicoSearch,
        join: ns in NoteSearch, on: ps.note_search_id == ns.id,
        where: ns.search_id == ^search.id,
        preload: [:note_search, note_search: :search]

      Repo.one(query)
    else
      nil
    end
  end

  def get_related_pico_outcomes(ps_id) do
    1..9
    |> Enum.map(
    fn(index) ->
      from po in PicoOutcome,
      where: po.pico_search_id == ^ps_id and po.o_index == ^index,
      order_by: [desc: po.id],
      limit: 1
    end)
    |> Enum.map(&Repo.one/1)
    |> Enum.reject(&(&1 == nil))
  end
end
