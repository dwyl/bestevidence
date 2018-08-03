defmodule Bep.PicoSearch do
  @moduledoc """
  PicoSearch model
  """
  use Bep.Web, :model
  alias Bep.{NoteSearch, PicoOutcome}

  schema "pico_searches" do
    belongs_to :note_search, NoteSearch
    field :p, :string
    field :i, :string
    field :c, :string
    field :position, :string
    field :probability, :integer
    has_many :pico_outcome, PicoOutcome
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    params_list = [:p, :i, :c, :position, :probability]

    struct
    |> cast(params, params_list)
  end
end
