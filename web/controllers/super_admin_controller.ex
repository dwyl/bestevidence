defmodule Bep.SuperAdminController do
  use Bep.Web, :controller
  alias Bep.{Client, Repo}
  alias ExAws.S3
  @ex_aws Application.get_env(:bep, :ex_aws)

  def index(conn, _params) do
    clients = Repo.all(Client)
    render(conn, "index.html", hide_navbar: true, clients: clients)
  end

  def new(conn, _params) do
    changeset = Client.changeset(%Client{})
    render(conn, "new.html", changeset: changeset, hide_navbar: true)
  end

  def create(conn, %{"client" => client_map}) do
    file_uuid = UUID.uuid4(:hex)
    client_logo = client_map["client_logo"]
    filename = client_logo.filename
    path = client_logo.path
    unique_filename = "#{file_uuid}-#{filename}"
    logo_url = create_url(unique_filename)
    binary = File.read!(path)

    request =
      "AWS_FOLDER"
      |> System.get_env()
      |> S3.put_object(unique_filename, binary)
      |> @ex_aws.request

    client_map =
      Map.update(client_map, "logo_url", logo_url, fn(_value) ->
        logo_url
      end)

    changeset = Client.changeset(%Client{}, client_map)

    case request do
      {:ok, _term} ->
        case Repo.insert(changeset) do
          {:ok, _entry} ->
            redirect(conn, to: super_admin_path(conn, :index))
          {:error, changeset} ->
            render(conn, "new.html", changeset: changeset, hide_navbar: true)
        end
      {:error, _term} ->
        render(conn, "new.html", changeset: changeset, hide_navbar: true)
    end
  end

  defp create_url(unique_filename) do
    aws_bucket = System.get_env("AWS_BUCKET")
    aws_region = System.get_env("AWS_REGION")
    aws_folder_name = System.get_env("AWS_FOLDER")

    "https://s3-#{aws_region}.amazonaws.com/#{aws_bucket}/#{aws_folder_name}/#{unique_filename}"
  end

  def edit(conn, %{"id" => client_id}) do
    client = Repo.get(Client, client_id)
    changeset = Client.changeset(client)

    render(
      conn,
      "edit.html",
      client: client,
      changeset: changeset,
      hide_navbar: true
    )
  end

  def update(conn, %{"id" => client_id, "client" => client_map}) do
    client = Repo.get(Client, client_id)
    changeset = Client.changeset(client, client_map)

    case Repo.update(changeset) do
      {:ok, _entry} ->
        redirect(conn, to: super_admin_path(conn, :index))
      {:error, changeset} ->
        render(
          conn,
          "edit.html",
          client: client,
          changeset: changeset,
          hide_navbar: true
        )
    end
  end
end
