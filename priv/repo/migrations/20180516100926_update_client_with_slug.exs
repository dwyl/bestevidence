defmodule Bep.Repo.Migrations.UpdateClientWithSlug do
  use Ecto.Migration

  def change do
    alter table(:clients) do
      add :slug, :string, null: false
    end

    create unique_index(:clients, [:slug])
  end
end
