defmodule Bep.Publication do
  @moduledoc """
  Publication model
  """
  use Bep.Web, :model
  alias Bep.Search

  schema "publications" do
    field :url, :string
    field :value, :string
    belongs_to :search, Search

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:url, :value, :search_id])
    |> validate_required([:url, :value, :search_id])
  end
end
