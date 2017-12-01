defmodule Bep.PasswordReset do
  @moduledoc """
  tokens for password resets
  """
  use Bep.Web, :model
  alias Bep.{User}

  schema "password_resets" do
    belongs_to	:user, User
    field :token, :string
    field :token_expires, :utc_datetime
    timestamps()
  end

  def changeset(model, params) do
    model
    |> cast(params, [:token])
    |> validate_required([:token])
    |> put_expiry
  end

  defp put_expiry(changeset) do
    put_change(changeset, :token_expires, Timex.shift(Timex.now, hours: 2))
  end
end
