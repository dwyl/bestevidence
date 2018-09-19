defmodule Bep.User do
  @moduledoc """
  User model with email and password
  """
  use Bep.Web, :model
  alias Comeonin.Bcrypt
  alias Bep.{Client, NotePublication, Search, Type, UserType}

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many :searches, Search
    has_many :password_resets, Bep.PasswordReset
    has_many :note_publications, NotePublication
    many_to_many :types, Type, join_through: UserType, on_replace: :delete
    belongs_to :client, Client

    timestamps()
  end

  def changeset(model, params \\ :invalid) do
    model
    |> cast(params, [:email])
    |> validate_required([:email])
    |> email_lowercase()
    |> validate_format(:email, ~r/@/)
    |> put_email_hash()
    |> unique_constraint(:email)
  end

  def ca_changeset(model, params \\ :invalid) do
    model
    |> cast(params, [:email])
    |> validate_required([:email])
    |> email_lowercase()
    |> validate_format(:email, ~r/@/)
    |> put_email_hash()
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password, message: "Passwords do not match")
    |> put_pass_hash()
  end

  def change_password_changeset(model, params) do
    model
    |> cast(params, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password, message: "Passwords do not match")
    |> put_pass_hash()
  end

  defp put_email_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{email: email}} ->
        hashed_email = hash_str(email)

        put_change(changeset, :email, hashed_email)
      _ ->
        changeset
    end
  end

  def hash_str(str) do
    :sha256
    |> :crypto.hash(str)
    |> Base.encode16()
    |> String.downcase()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

  defp email_lowercase(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{email: email}} ->
        put_change(
          changeset,
          :email,
          email
          |> String.downcase()
          |> String.trim()
        )
      _ ->
        changeset
    end
  end

  def filter_admin_users(users) do
    Enum.filter(
      users,
      &!Type.is_type?(&1.types, "super-admin") &&
      !Type.is_type?(&1.types, "client-admin")
    )
  end
end
