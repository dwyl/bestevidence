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
    |> check_to_fields()
  end

  defp check_to_fields(changeset) do
    [:to_all, :to_client, :to_user]
    |> Enum.map(fn(el) ->
      validate_required(changeset, [el])
    end)
    |> check_to_changesets(changeset)
    |> update_to_all()
  end

  defp check_to_changesets(changesets, changeset) do
    case Enum.any?(changesets, &is_cs_valid?/1) do
      true ->
        changeset
      _ ->
        add_error(changeset, :to, "all to fields were left empty")
    end
  end

  defp is_cs_valid?(changeset) do
    changeset.valid?
  end

  defp update_to_all(changeset) do
    changeset
    |> validate_required([:to_all])
    |> is_cs_valid?()
    |> case  do
      false ->
        put_change(changeset, :to_all, false)
      true ->
        # this could just return changeset
        # will need to double check this
        put_change(changeset, :to_all, true)
    end
  end

  # Helpers

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
    |> User.filter_admin_user()
  end
end
