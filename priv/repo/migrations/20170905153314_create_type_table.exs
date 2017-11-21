defmodule Bep.Repo.Migrations.CreateTypeTable do
  use Ecto.Migration

  def change do
    create table(:types) do
      add :type, :string

    end

    create unique_index(:types, [:type])
  end
end
