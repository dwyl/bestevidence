defmodule Bep.Repo.Migrations.CreatePublicationsTable do
  use Ecto.Migration

  def change do
    create table(:publications) do
      add :url, :string, null: false
      add :value, :string
      add :search_id, references(:searches, on_delete: :nothing)
      timestamps()
    end
    create index(:publications, [:search_id] )
  end
end
