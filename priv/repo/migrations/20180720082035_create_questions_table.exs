defmodule Bep.Repo.Migrations.CreateQuestionsTable do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :section, :string
      add :question, :string
    end
  end
end
