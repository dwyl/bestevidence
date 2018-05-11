defmodule Bep.Repo.Migrations.AddClient do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:clients, [:name])
  end
end
