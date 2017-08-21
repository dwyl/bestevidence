defmodule Bep.Repo.Migrations.CreateNotePublicationTable do
  use Ecto.Migration

  def change do
    create table(:note_publications) do
      add :note, :string
      add :publication_id, references(:publications, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :delete_all)
      timestamps()
    end
    create index(:note_publications, [:publication_id] )
    create index(:note_publications, [:user_id] )
  end
end
