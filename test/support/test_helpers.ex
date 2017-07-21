
defmodule ResearchResource.TestHelpers do
  alias Bep.{Repo, User}
  alias Plug.Conn
  alias Phoenix.ConnTest

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(%{
      email: "email@example.com",
      password: "supersecret",
    }, attrs)

    %User{}
    |> User.registration_changeset(changes)
    |> Repo.insert!()
  end
end
