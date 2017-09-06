defmodule Bep.Repo.Migrations.CreateUserTypeTable do
  use Ecto.Migration

  def change do
    create table(:users_types, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :type_id, references(:types, on_delete: :nothing)
    end
  end
end
