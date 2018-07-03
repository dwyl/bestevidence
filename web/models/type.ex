defmodule Bep.Type do
  @moduledoc """
  Type model
  """
  use Bep.Web, :model
  alias Bep.{Repo, Type, User}

  schema "types" do
    field :type, :string
    many_to_many :users, User, join_through: UserType, on_replace: :delete
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:type])
    |> validate_required([:type])
  end

  def get_list do
    [
      "doctor",
      "nurse",
      "other healthcare professional",
      "healthcare manager or policy maker",
      "academic",
      "undergraduate student",
      "postgraduate student",
      "lay member of public",
      "other"
    ]
  end

  def filter_super_admin(list) do
    Enum.filter(list, fn(el) -> el.type != "super-admin" end)
  end

  def separate_other(list) do
    index = Enum.find_index(list, &(&1.type == "other"))
    List.pop_at(list, index)
  end

  def get_types do
    Type
    |> Repo.all()
    |> Type.filter_super_admin
  end

  def is_type_admin?(types) do
    Enum.any?(types, &(&1.type == "super-admin"))
  end
end
