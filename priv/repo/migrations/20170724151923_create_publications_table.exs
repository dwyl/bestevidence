defmodule Bep.Repo.Migrations.CreatePublicationsTable do
  use Ecto.Migration

  def change do
    create table(:publications) do
      add :url, :string, null: false
      add :value, :string
      add :tripdatabase_id, :string
      timestamps()
    end
    create unique_index(:publications, [:tripdatabase_id] )
  end
end
