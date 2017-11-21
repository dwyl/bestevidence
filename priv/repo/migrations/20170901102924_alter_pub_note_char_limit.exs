defmodule Bep.Repo.Migrations.AlterPubNoteCharLimit do
  use Ecto.Migration

  def change do
    alter table(:note_publications) do
     modify :note, :text
    end
  end
end
