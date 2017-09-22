defmodule Bep.Repo.Migrations.AlterSearchTerm do
  use Ecto.Migration

  def change do
    alter table(:searches) do
     modify :term, :text, null: false
    end
  end
end
