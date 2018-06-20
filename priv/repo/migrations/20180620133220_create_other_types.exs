defmodule Bep.Repo.Migrations.CreateOtherTypes do
  use Ecto.Migration
  alias Bep.{OtherType, Repo, User}

  def up do
    create table(:other_types, primary_key: false) do
      add :user_id, references(:users)
      add :type, :string
    end

    flush()
    does_user_have_other_type? =
      fn(user) ->
        user.types
        |> Enum.any?(&(&1.type == "other"))
      end

    insert_other_type =
      fn(user) ->
        if does_user_have_other_type?.(user) do
          Repo.insert!(%OtherType{user_id: user.id, type: "special"})
        else
          Repo.insert!(%OtherType{user_id: user.id, type: ""})
        end
      end

    Repo.all(User)
    |> Repo.preload(:types)
    |> Enum.map(fn(user) ->
      insert_other_type.(user)
    end)
  end

  def down do
    drop table(:other_types)
  end
end
