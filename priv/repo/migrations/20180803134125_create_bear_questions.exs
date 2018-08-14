defmodule Bep.Repo.Migrations.CreateBearQuestions do
  use Ecto.Migration

  def change do
    create table(:bear_questions) do
      add :section, :string
      add :question, :string
    end

    create unique_index(:bear_questions, [:section, :question])
  end
end
