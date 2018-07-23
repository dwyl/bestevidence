defmodule Bep.PicoOutcome do
  @moduledoc """
  PicoSearch model
  """
  use Bep.Web, :model
  alias Bep.PicoSearch

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
end
