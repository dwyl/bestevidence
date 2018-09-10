defmodule Bep.PicoOutcome do
  @moduledoc """
  PicoSearch model
  """
  use Bep.Web, :model
  alias Bep.{PicoOutcome, PicoSearch, Repo}

  schema "pico_outcomes" do
    belongs_to :pico_search, PicoSearch
    field :o, :string
    field :o_index, :integer
    field :benefit, :boolean
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    params_list = [:o, :o_index, :benefit]

    struct
    |> cast(params, params_list)
  end

  # HELPERS
  def get_pico_outcomes(pico_search_id) do
    Repo.all(
      from po in PicoOutcome,
      where: po.pico_search_id == ^pico_search_id,
      order_by: [desc: po.id],
      limit: 9
    )
  end

  def unique_outcomes(pico_outcomes) do
    pico_outcomes
    |> Enum.sort(&(&1.o_index < &2.o_index))
    |> Enum.uniq_by(&(&1.o_index))
  end
end
