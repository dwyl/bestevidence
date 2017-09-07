defmodule Bep.UserType do
  @moduledoc """
  relations table for users and types
  """
  use Bep.Web, :model
  alias Bep.{User, Type}
  @primary_key false
  schema "users_types" do
    belongs_to	:user, User
    belongs_to	:type, Type
  end
end
