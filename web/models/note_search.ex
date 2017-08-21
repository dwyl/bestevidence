defmodule Bep.NoteSearch do
  @moduledoc """
  note search model
  """
  use Bep.Web, :model
  alias Bep.Search

  schema "note_searches" do
    field :note, :string
    belongs_to :search, Search

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:note, :search_id])
    |> validate_required([:search_id])
  end
end
