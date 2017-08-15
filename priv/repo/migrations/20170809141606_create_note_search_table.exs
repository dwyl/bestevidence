defmodule Bep.Repo.Migrations.CreateNoteSearchTable do
  use Ecto.Migration

  def change do
    create table(:note_searches) do
      add :note, :string
      add :search_id, references(:searches, on_delete: :delete_all)
      timestamps()
    end
    create index(:note_searches, [:search_id] )
  end
end
