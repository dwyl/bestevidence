defmodule Bep.Repo.Migrations.CreatePicoOutcome do
  use Ecto.Migration

  def change do
    create table(:pico_outcomes) do
      add :pico_search_id, references(:pico_searches, on_delete: :delete_all)
      add :o, :string
      add :o_index, :integer
      add :benefit, :bool

      timestamps()
    end
  end
end
