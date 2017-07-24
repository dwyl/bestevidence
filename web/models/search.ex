defmodule Bep.Search do
  @moduledoc """
  Search model
  """
  use Bep.Web, :model
  alias Bep.{User, Publication}

  schema "searches" do
    field :term, :string
    field :number_results, :integer
    belongs_to :user, User
    has_many :publications, Publication
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:term])
    |> validate_required([:term])
  end

  def create_changeset(model, params, number_results) do
    model
    |> changeset(params)
    |> put_change(:number_results, number_results)
  end
end
