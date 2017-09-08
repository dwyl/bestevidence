defmodule Bep.Repo.Migrations.CreateTableSearchesPublications do
  use Ecto.Migration

  def change do
    create table(:searches_publications, primary_key: false) do
      add :search_id, references(:searches)
      add :publication_id, references(:publications)
      timestamps()
    end
    create unique_index(:searches_publications, [:search_id, :publication_id])
  end
end
