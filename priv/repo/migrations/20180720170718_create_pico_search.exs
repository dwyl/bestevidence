defmodule Bep.Repo.Migrations.CreatePicoSearch do
  use Ecto.Migration

  def change do
    create table(:pico_searches) do
      add :note_search_id, references(:note_searches, on_delete: :delete_all)
      add :p, :string
      add :i, :string
      add :c, :string
      add :position, :string
      add :probability, :integer

      timestamps()
    end
  end
end
