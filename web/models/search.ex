defmodule Bep.Search do
  @moduledoc """
  Search model
  """
  use Bep.Web, :model
  alias Bep.{
    Tripdatabase.HTTPClient, User, Publication, NoteSearch, SearchPublication,
    Repo
  }

  schema "searches" do
    field :term, :string
    field :number_results, :integer
    belongs_to :user, User
    many_to_many :publications, Publication,
      join_through: SearchPublication,
      unique: true
    has_one :note_searches, NoteSearch
    field :uncertainty, :boolean
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

  def search_data_for_create(search_params, _user) do
    term = search_params["term"]
    data =
      case HTTPClient.search(term) do
        {:error, _} ->
          %{"total" => 0, "documents" => []}
        {:ok, res} ->
          res
      end

    trimmed_term = term |> String.trim |> String.downcase

    %{
      term: term,
      trimmed_term: trimmed_term,
      data: data
    }
  end

  def get_publications(_u, tripdatabase_ids) do
    publications =
      from p in Publication,
      where: p.tripdatabase_id in ^tripdatabase_ids

    Repo.all(publications)
  end

  def link_publication_notes(data, publications) do
    documents = Enum.map(data["documents"], fn(evidence) ->
      publication = Enum.find(publications, fn(p) ->
          p.tripdatabase_id == evidence["id"]
        end)
        publication_id = publication && publication.id
        Map.put(evidence, :publication_id, publication_id)
      end)
    Map.put(data, "documents", documents)
  end
end
