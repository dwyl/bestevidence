defmodule Bep.Messages do
  use Bep.Web, :model
  alias Bep.{Messages, Repo, User}

  @moduledoc false

  schema "messages" do
    field :subject, :string
    field :body, :string
    field :to_all, :boolean
    field :to_client, :id
    field :to_user, :id
    field :from_id, :id

    timestamps()
  end

  def changeset(struct, params \\%{}) do
    params_list = [:subject, :body, :to_all, :to_client, :to_user, :from_id]

    struct
    |> cast(params, params_list)
    |> validate_required([:subject, :body, :from_id])
  end

  # Helpers
  def get_to_assigns(map) do
    [
      to_all: map["to_all"],
      to_client: map["to_client"],
      to_user: map["to_user"]
    ]
  end

  def create_to_params(%{"to_user" => to}) do
    [
      to_all: "false",
      to_client: "",
      to_user: to
    ]
  end

  def create_to_params(%{"to_client" => to}) do
    [
      to_all: "false",
      to_client: to,
      to_user: ""
    ]
  end

  def create_to_params(%{"to_all" => to}) do
    [
      to_all: to,
      to_client: "",
      to_user: ""
    ]
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

  def get_user_list(user, type) do
    query =
      if type == "super-admin" do
        User
      else
        from(
          u in User,
          where: u.client_id == ^user.client_id
          and u.id != ^user.id
        )
      end

    query
    |> Repo.all()
    |> Repo.preload(:types)
    |> User.filter_admin_user()
  end
end
