defmodule Bep.OtherType do
  @moduledoc """
  tokens for password resets
  """
  use Bep.Web, :model

  @primary_key false
  schema "other_types" do
    field :user_id, :integer
    field :type, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:type])
  end
end
