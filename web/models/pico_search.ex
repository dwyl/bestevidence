defmodule Bep.PicoSearch do
  @moduledoc """
  PicoSearch model
  """
  use Bep.Web, :model
  alias Bep.NoteSearch

  schema "publications" do
    belongs_to :note_search, NoteSearch
    field :p, :string
    field :i, :string
    field :c, :string
    field :o, :string
    field :o_index, :integer
    field :benefit, :boolean
    field :position, :string
    field :probability, :integer
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    params_list = [:p, :i, :c, :o, :o_index, :benefit, :position, :probability]

    struct
    |> cast(params, params_list)
  end
end
