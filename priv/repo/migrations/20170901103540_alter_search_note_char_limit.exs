defmodule Bep.Repo.Migrations.AlterSearchNoteCharLimit do
  use Ecto.Migration

  def change do
    alter table(:note_searches) do
     modify :note, :text
    end
  end
end
