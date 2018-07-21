defmodule Bep.PasswordReset do
  @moduledoc """
  tokens for password resets
  """
  use Bep.Web, :model
  alias Bep.{User}

  schema "password_resets" do
    belongs_to :user, User
    field :token, :string
    field :token_expires, :utc_datetime
    timestamps()
  end

  def changeset(model, params, time) do
    model
    |> cast(params, [:token])
    |> validate_required([:token])
    |> put_expiry(time)
  end

  defp put_expiry(changeset, time) do
    put_change(changeset, :token_expires, Timex.shift(Timex.now, time))
  end
end
