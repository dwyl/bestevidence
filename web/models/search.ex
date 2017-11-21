defmodule Bep.Search do
  @moduledoc """
  Search model
  """
  use Bep.Web, :model
  alias Bep.{User, Publication, NoteSearch, SearchPublication}

  schema "searches" do
    field :term, :string
    field :number_results, :integer
    belongs_to :user, User
    many_to_many :publications, Publication,
      join_through: SearchPublication,
      unique: true
    has_one :note_searches, NoteSearch
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:term])
    |> validate_required([:term])
    |> trim_term()
  end

  def create_changeset(model, params, number_results) do
    model
    |> changeset(params)
    |> put_change(:number_results, number_results)
  end

  defp trim_term(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{term: term}} ->
        searched_term = term
          |> String.trim()
          |> String.downcase()
        put_change(changeset, :term, searched_term)
      _ ->
        changeset
    end
  end

  def group_searches_by_day(searches) do
    searches
    |> Enum.group_by(
      fn(s) -> Date.to_string(s.updated_at)
    end)
    |> Enum.sort(fn({k1, _}, {k2, _}) -> k1 >= k2 end)
  end
end
