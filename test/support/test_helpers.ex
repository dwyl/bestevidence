
defmodule Bep.TestHelpers do
  alias Bep.{Repo, User, Search ,NoteSearch}

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
    NoteSearch.changeset(%NoteSearch{}, %{"note" => "test note", "search_id" => search.id})
    |> Repo.insert!()
  end

  def insert_search() do
    Search.create_changeset(%Search{}, %{"term" => "search test"}, 100)
    |> Repo.insert!()
  end
end
