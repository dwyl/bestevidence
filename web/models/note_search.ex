defmodule Bep.NoteSearch do
  @moduledoc """
  note search model
  """
  use Bep.Web, :model
  alias Bep.{Search, PicoSearch}

  schema "note_searches" do
    field :note, :string
    field :note_complete, :boolean, default: false
    belongs_to :search, Search
    has_many :pico_search, PicoSearch

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:note, :search_id, :note_complete])
    |> validate_required([:search_id, :note_complete])
  end
end
