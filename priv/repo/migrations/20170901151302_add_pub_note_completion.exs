defmodule Bep.Repo.Migrations.AddPubNoteCompletion do
  use Ecto.Migration

  def change do
    alter table(:note_publications) do
      add :note_complete, :boolean, default: false
    end
  end
end
