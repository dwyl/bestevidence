defmodule Bep.Repo.Migrations.CreateTableSearchesPublications do
  use Ecto.Migration

  def change do
    create table(:searches_publications, primary_key: false) do
      add :search_id, references(:searches)
      add :publication_id, references(:publications)
      timestamps()
    end
  end
end
