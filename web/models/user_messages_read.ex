defmodule Bep.UserMessagesRead do
  @moduledoc """
  UserMessagesRead model
  """

  use Bep.Web, :model
  alias Bep.{Repo, User, UserMessagesRead}

  @primary_key false
  schema "user_messages_read" do
    belongs_to :user, User, primary_key: true
    field :messages_read_at, :utc_datetime
    field :message_received_at, :utc_datetime
  end

  def new_msg_changeset(struct, params \\ %{}) do
    date_time_now = DateTime.utc_now()

    struct
    |> cast(params, [:user_id, :message_received_at])
    |> validate_required([:user_id, :message_received_at])
    |> put_change(:message_received_at, date_time_now)
  end

  def read_msg_changeset(struct, params \\ %{}) do
    date_time_now = DateTime.utc_now()

    struct
    |> cast(params, [:user_id, :messages_read_at])
    |> validate_required([:user_id, :messages_read_at])
    |> put_change(:message_received_at, date_time_now)
  end
  # Helpers

  def update_user_msg_received(message) do
    if is_integer(message.to_user) do
      UserMessagesRead
      |> Repo.get(message.to_user)
      |> UserMessagesRead.new_msg_changeset()
      |> Repo.update!
    end
  end
end
