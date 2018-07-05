defmodule Bep.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :subject, :text, null: false
      add :body, :text, null: false
      add :to_all, :bool, null: false
      add :to_client, references("clients")
      add :to_user, references("users")
      add :from_id, references("users"), null: false

      timestamps()
    end
  end
end
