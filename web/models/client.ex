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
    field :slug, :string
    has_many :users, Bep.User

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    fields = [
      :name,
      :login_page_bg_colour,
      :btn_colour,
      :search_bar_colour,
      :about_text,
      :slug
    ]

    model
    |> cast(params, fields)
    |> validate_required(fields)
    |> slug_lowercase()
    |> validate_format(:slug, ~r/[a-zA-Z]/)
    |> validate_format(:login_page_bg_colour, ~r/^\#[A-Fa-f0-9]{6,6}$/)
    |> validate_format(:btn_colour, ~r/^\#[A-Fa-f0-9]{6,6}$/)
    |> validate_format(:search_bar_colour, ~r/^\#[A-Fa-f0-9]{6,6}$/)
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end

  defp slug_lowercase(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{slug: slug}} ->
        put_change(
          changeset,
          :slug,
          slug
          |> String.downcase()
          |> String.trim()
        )
      _ ->
        changeset
    end
  end
end
