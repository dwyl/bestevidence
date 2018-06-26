defmodule Bep.Messages do
  use Bep.Web, :model
  alias Bep.{Messages, Repo, Type, User}

  @moduledoc false

  schema "messages" do
    field :subject, :string
    field :body, :string
    field :to_all, :boolean
    field :to_client, :id
    field :to_user, :id
    field :from_id, :id
  end

  def get_messages(conn) do
    client_id = conn.assigns.client.id
    current_user_id = conn.assigns.current_user.id

    query = 
      from m in Messages,
      where: m.to_all == true
      or m.to_client == ^client_id
      or m.to_user == ^current_user_id

    Repo.all(query)
  end

  def get_user_list do
    User
    |> Repo.all()
    |> Repo.preload(:types)
    |> filter_admin_user()
  end

  defp filter_admin_user(users) do
    Enum.filter(users, &any_admins?(&1.types))
  end

  defp any_admins?(types) do
    Enum.any?(types, &(&1.type != "super-admin"))
  end
end
