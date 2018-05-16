defmodule Bep.TestHelpers do
  @moduledoc """
  helper functions for the tests
  """
  alias Bep.{
    Client, Repo, User, Search, NoteSearch, NotePublication, Publication, Type
  }
  alias Ecto.Changeset

  def insert_user(type \\ "test_type", attrs \\ %{}) do
    changes = Map.merge(%{
      email: "email@example.com",
      password: "supersecret",
    }, attrs)

    type = Repo.insert!(%Type{type: type})

    %User{}
    |> User.registration_changeset(changes)
    |> Changeset.put_assoc(:types, [type])
    |> Repo.insert!()
  end

  def insert_client(attrs \\ %{}) do
    changes = Map.merge(%{
      name: "testClient",
      login_page_bg_colour: "#4386f4",
      btn_colour: "#4386f4",
      search_bar_colour: "#4386f4",
      about_text: "about text",
      slug: "testSlug"
    }, attrs)

    %Client{}
    |> Client.changeset(changes)
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
    types = Type.get_list

    for type <- types do
      Repo.insert!(%Type{type: type})
    end
  end

  def change_password_map(current, new, confirm) do
    %{
      "change_password" => %{
        "current_password" => current,
        "new_password" => new,
        "new_password_confirmation" => confirm
      }
    }
  end
end
