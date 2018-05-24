defmodule Bep.UploadLogo.Prod do
  alias ExAws.S3
  @moduledoc false

  def upload_logo_to_s3(path, unique_filename) do
    binary = File.read!(path)

    "AWS_FOLDER"
    |> System.get_env()
    |> S3.put_object(unique_filename, binary)
    |> ExAws.request
  end
end
