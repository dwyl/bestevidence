defmodule Bep.Repo.Migrations.AddUncertaintyToSearches do
  use Ecto.Migration

  def change do
    alter table(:searches) do
      add :uncertainty, :boolean, default: false
    end
  end
end
