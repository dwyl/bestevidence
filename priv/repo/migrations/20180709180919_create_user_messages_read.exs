defmodule Bep.Repo.Migrations.CreateUserMessagesRead do
  use Ecto.Migration
  alias Bep.{Repo, User, UserMessagesRead}

  def up do
    create table(:user_messages_read, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
      add :messages_read_at, :utc_datetime
      add :message_received_at, :utc_datetime
    end
    create unique_index(:user_messages_read, [:user_id])

    flush()

    date_time_now = DateTime.utc_now()

    User
    |> Repo.all()
    |> Enum.map(fn(user) ->
      Repo.insert(
        %UserMessagesRead{
          user_id: user.id,
          messages_read_at: date_time_now,
          message_received_at: date_time_now
        }
      )
    end)
  end

  def down do
    drop table(:user_messages_read)
  end
end
