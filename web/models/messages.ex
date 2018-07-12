defmodule Bep.Messages do
  use Bep.Web, :model
  alias Bep.{Client, Messages, Repo, Type, User, UserType}

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

    users_client = Repo.get(Client, users_client_id)
    get_sa_query =
      from u in User,
      join: ut in UserType, on: u.id == ut.user_id,
      join: t in Type, on: t.id == ut.type_id,
      where: t.type == "super-admin"

    super_admin_id = Repo.all(get_sa_query)

    query =
      from(
        m in Messages,
        where: m.to_all == true
        or m.to_client == ^users_client_id
        or m.to_user == ^user_id,
        order_by: [desc: m.inserted_at]
      )

    admin_str = "BestEvidence Administrator"
    cli_name = users_client.name <> " Administrator"
    cli_colour = users_client.login_page_bg_colour

    query
    |> Repo.all()
    |> Enum.map(fn(msg) ->
      from = msg_map_helper(msg, super_admin_id, admin_str, cli_name)
      colour = msg_map_helper(msg, super_admin_id, "#4A90E2", cli_colour)

      msg
      |> Map.put(:from, from)
      |> Map.put(:colour, colour)
    end)
  end

  defp msg_map_helper(msg, sa_id, sa_var, ca_var) do
    cond do
      msg.to_all == true ->
        sa_var
      msg.to_client != nil ->
        ca_var
      true ->
        case msg.from_id == sa_id do
          true ->
            sa_var
          _ ->
          ca_var
        end
    end
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
