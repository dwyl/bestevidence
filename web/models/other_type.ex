defmodule Bep.OtherType do
  @moduledoc """
  tokens for password resets
  """
  use Bep.Web, :model
  alias Bep.User

  @primary_key false
  schema "other_types" do
    belongs_to :user, User
    field :type, :string
  end
end
