defmodule Bep.NotePublication do
  @moduledoc """
  note publication schema
  """
  use Bep.Web, :model
  alias Bep.User

  schema "note_publications" do
    field :note, :string
    belongs_to :publication, Search
    belongs_to :user, User
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:note, :publication_id, :user_id])
    |> validate_required([:publication_id, :user_id])
  end
end
