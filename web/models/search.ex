defmodule Bep.Search do
  @moduledoc """
  Search model
  """
  use Bep.Web, :model
  alias Bep.{
    Tripdatabase.HTTPClient, User, Publication, NoteSearch, NotePublication,
    SearchPublication, Repo
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

  def search_data_for_create(search_params, user) do
    term = search_params["term"]
    data =
      case HTTPClient.search(term) do
        {:error, _} ->
          %{"total" => 0, "documents" => []}
        {:ok, res} ->
          res
      end

    tripdatabase_ids = Enum.map(data["documents"], &(&1["id"]))
    pubs = get_publications(user, tripdatabase_ids)
    data = link_publication_notes(data, pubs)
    trimmed_term = term |> String.trim |> String.downcase

    %{
      term: term,
      trimmed_term: trimmed_term,
      data: data
    }
  end

  def get_publications(u, tripdatabase_ids) do
    user_note = from np in NotePublication, where: np.user_id == ^u.id
    publications = from p in Publication,
      where: p.tripdatabase_id in ^tripdatabase_ids,
      preload: [note_publications: ^user_note]
    Repo.all(publications)
  end

  def link_publication_notes(data, publications) do
    documents = Enum.map(data["documents"], fn(evidence) ->
      publication = Enum.find(
        publications,
        fn(p) -> p.tripdatabase_id == evidence["id"] end
      )
      note_publications = publication && publication.note_publications
      publication_id = publication && publication.id
      evidence
      |> Map.put(:note_publications, note_publications || [])
      |> Map.put(:publication_id, publication_id)
    end)
    Map.put(data, "documents", documents)
  end

end
