defmodule Bep.Client do
  @moduledoc """
  Client model
  """
  use Bep.Web, :model
  alias ExAws.S3
  @ex_aws Application.get_env(:bep, :ex_aws)

  schema "clients" do
    field :name, :string
    field :login_page_bg_colour, :string
    field :btn_colour, :string
    field :search_bar_colour, :string
    field :about_text, :string
    field :slug, :string
    field :client_logo, :map, virtual: true
    field :logo_url, :string
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
      :slug,
    ]

    hex_message = "Please use a valid hex value (e.g. #4286f4)"
    hex_reg = ~r/^\#[A-Fa-f0-9]{6,6}$/
    slug_reg = ~r/[a-zA-Z]/

    model
    |> cast(params, fields)
    |> validate_required(fields)
    |> slug_lowercase()
    |> validate_format(:slug, slug_reg)
    |> validate_format(:login_page_bg_colour, hex_reg, message: hex_message)
    |> validate_format(:btn_colour, hex_reg, message: hex_message)
    |> validate_format(:search_bar_colour, hex_reg, message: hex_message)
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end

  def logo_changeset(model, params \\ :invalid) do
    model
    |> changeset(params)
    |> cast(params, [:client_logo])
    |> put_logo_url()
  end

  defp put_logo_url(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{client_logo: client_logo}} ->
        file_uuid = UUID.uuid4(:hex)
        filename = client_logo.filename
        path = client_logo.path
        unique_filename = "#{file_uuid}-#{filename}"
        logo_url = create_url(unique_filename)
        binary = File.read!(path)

        "AWS_FOLDER"
        |> System.get_env()
        |> S3.put_object(unique_filename, binary)
        |> @ex_aws.request

        put_change(changeset, :logo_url, logo_url)
      _ ->
        changeset
        |> validate_required(:client_logo)
    end
  end

  defp create_url(unique_filename) do
    aws_bucket = System.get_env("AWS_BUCKET")
    aws_region = System.get_env("AWS_REGION")
    aws_folder_name = System.get_env("AWS_FOLDER")

    "https://s3-#{aws_region}.amazonaws.com/#{aws_bucket}/#{aws_folder_name}/#{unique_filename}"
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
