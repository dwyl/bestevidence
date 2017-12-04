defmodule Bep.Repo.Migrations.PasswordReset do
  use Ecto.Migration

  def change do
    create table(:password_resets) do
      add :token, :string
      add :user_id, references(:users, on_delete: :delete_all)
      add :token_expires, :utc_datetime

      timestamps()
    end
    create index(:password_resets, [:user_id])
  end
end
