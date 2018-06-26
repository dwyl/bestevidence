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

  def get_messages(user_id) do
    users_client_id =
      User
      |> Repo.get!(user_id)
      |> Map.get(:client_id)

    query =
      from(
        m in Messages,
        where: m.to_all == true
        or m.to_client == ^users_client_id
        or m.to_user == ^user_id
      )

      Repo.all(query)
  end

  def get_user_list do
    User
    |> Repo.all()
    |> Repo.preload(:types)
    |> filter_admin_user()
  end

  def filter_admin_user(users) do
    Enum.filter(users, &!is_type_admin?(&1.types))
  end

  def is_type_admin?(types) do
    Enum.any?(types, &(&1.type == "super-admin"))
  end
end
