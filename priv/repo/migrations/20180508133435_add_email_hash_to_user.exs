defmodule Bep.Repo.Migrations.AddEmailHashToUser do
  use Ecto.Migration
  import Ecto.Query
  alias Bep.{Repo, User}

  def up do
    alter table(:users) do
      add :email_hash, :string
    end

    flush()
    create unique_index(:users, [:email_hash])

    Bep.Repo.all(User)
    |> Enum.map(fn(user) ->
      hashed_email =
        case String.contains?(user.email, "@") do
          true -> Bep.User.hash_str(user.email)
          _ -> user.email
        end

      from(u in "users",
        update: [set: [email_hash: ^hashed_email]],
        where: ^user.email == u.email
      )
    end)
    |> Enum.map(&Repo.update_all(&1, []))

    alter table(:users) do
      remove :email
    end
  end

  def down do
    alter table(:users) do
      add :email, :string
    end

    flush()

    from(u in "users",
      update: [set: [email: u.email_hash]]
    )
    |> Repo.update_all([])

    alter table(:users) do
      remove :email_hash
    end
  end
end
