defmodule Bep.Repo.Migrations.UpdateBearAnswersWithTimestamps do
  use Ecto.Migration

  def change do
    alter table(:bear_answers) do
      timestamps(default: NaiveDateTime.utc_now() |> NaiveDateTime.to_string(), null: false)
    end
  end
end
