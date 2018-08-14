defmodule Bep.Repo.Migrations.CreateBearAnswers do
  use Ecto.Migration

  def change do
    create table(:bear_answers) do
      add :bear_question_id, references(:bear_questions)
      add :publication_id, references(:publications)
      add :pico_search_id, references(:pico_searches)
      add :index, :integer
      add :answer, :string
    end
  end
end
