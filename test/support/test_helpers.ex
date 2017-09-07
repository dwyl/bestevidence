
defmodule Bep.TestHelpers do
  @moduledoc """
  helper functions for the tests
  """
  alias Bep.{Repo, User, Search, NoteSearch, NotePublication, Publication, Type}

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(%{
      email: "email@example.com",
      password: "supersecret",
    }, attrs)

    %User{}
    |> User.registration_changeset(changes)
    |> Repo.insert!()
  end

  def insert_search(user) do
    user
    |> Ecto.build_assoc(:searches)
    |> Search.create_changeset(%{"term" => "search test"}, 100)
    |> Repo.insert!()
  end

  def insert_note(search) do
    note = NoteSearch.changeset(
      %NoteSearch{},
      %{"note" => "test note", "search_id" => search.id}
    )
    Repo.insert!(note)
  end

  def insert_note_publication(publication, user) do
    note = NotePublication.changeset(
      %NotePublication{},
      %{
        "note" => "test note",
        "publication_id" => publication.id, "user_id" => user.id
        }
    )
    Repo.insert!(note)
  end

  def insert_publication(search) do
    publication = Publication.changeset(
      %Publication{},
      %{
        "url" => "/publication",
        "value" => "publication",
        "tripdatabase_id" => "1",
        "search_id" => "#{search.id}"
        }
    )
    Repo.insert!(publication)
  end

  def insert_types do
    types = [
      "doctor",
      "nurse",
      "other healthcare professional",
      "healthcare manager or policy maker",
      "academic",
      "undergraduate student",
      "postgraduate student",
      "Lay member of public"
    ]

    for type <- types do
      Repo.insert!(%Type{type: type})
    end
  end
end
