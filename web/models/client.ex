defmodule Bep.Client do
  @moduledoc """
  Client model 
  """
  use Bep.Web, :model

  schema "clients" do
    field :name, :string
    timestamps()
  end

  def changeset(model, params \\ :invalid) do
    model
    |> cast(params, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
