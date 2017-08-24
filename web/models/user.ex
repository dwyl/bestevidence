defmodule Bep.User do
  @moduledoc """
  User model with email and password
  """
  use Bep.Web, :model
  alias Comeonin.Bcrypt
  alias Bep.{Search, NotePublication}

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many :searches, Search
    has_many :note_publications, NotePublication
    timestamps()
  end

  def changeset(model, params \\ :invalid) do
    model
    |> cast(params, [:email])
    |> validate_required([:email])
    |> email_lowercase()
    |> validate_format(:email, ~r/.+\@.+\.\S+$/)
    |> unique_constraint(:email)
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 6)
    |> put_pass_hash()
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
        put_change(changeset, :email, String.downcase(email))
      _ ->
        changeset
    end
  end

end
