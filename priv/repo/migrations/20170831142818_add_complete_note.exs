defmodule Bep.Repo.Migrations.AddCompleteNote do
  use Ecto.Migration

  def change do
    alter table(:note_searches) do
      add :note_complete, :boolean, default: false
    end
  end
end
