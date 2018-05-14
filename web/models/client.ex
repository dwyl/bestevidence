defmodule Bep.Client do
  @moduledoc """
  Client model
  """
  use Bep.Web, :model

  schema "clients" do
    field :name, :string
    field :login_page_bg_colour, :string
    field :btn_colour, :string
    field :search_bar_colour, :string
    field :about_text, :string
    timestamps()
  end

  def changeset(model, params \\ :invalid) do
    fields = [
      :name, :login_page_bg_colour, :btn_colour, :search_bar_colour, :about_text
    ]
    model
    |> cast(params, fields)
    |> validate_required(fields)
    |> unique_constraint(:name)
  end
end
