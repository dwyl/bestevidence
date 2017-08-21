defmodule Bep.Repo.Migrations.CreateSearch do
  use Ecto.Migration

  def change do
    create table(:searches) do
      add :term, :string, null: false
      add :number_results, :integer
      add :user_id, references(:users, on_delete: :delete_all)
      timestamps()
    end
    create index(:searches, [:user_id] )
  end
end
