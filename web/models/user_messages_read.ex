defmodule Bep.UserMessagesRead do
  @moduledoc """
  UserMessagesRead model
  """

  use Bep.Web, :model
  alias Bep.{Messages, Repo, Type, User, UserMessagesRead}
  import Ecto.Query

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
    |> put_change(:messages_read_at, date_time_now)
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

  def insert_new_user_msg_read(user) do
    date_time_now = DateTime.utc_now()

    Repo.insert(%UserMessagesRead{
      user_id: user.id,
      messages_read_at: date_time_now,
      message_received_at: date_time_now
    })
  end

  def update_user_msg_read(user) do
    user_type = Type.get_user_type(user)
    if user_type == "regular" do
      UserMessagesRead
      |> Repo.get(user.id)
      |> case  do
        nil ->
          UserMessagesRead.insert_new_user_msg_read(user)
        user_message_read ->
          user_message_read
          |> UserMessagesRead.read_msg_changeset()
          |> Repo.update!
      end
    end
  end

  def new_msg_query(user) do
    from(umr in UserMessagesRead,
    join: m in Messages,
    where: umr.user_id == ^user.id
    and ((umr.message_received_at > umr.messages_read_at)
    or (m.to_client == ^user.client_id and m.updated_at > umr.messages_read_at)
    or (m.to_all == true and m.updated_at > umr.messages_read_at)
    ))
  end
end
