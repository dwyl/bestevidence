defmodule Bep.UploadLogo.Dev do
  @moduledoc false
  def upload_logo_to_s3(_path, file) do
    case String.contains?(file, "bad_file") do
      true -> {:error, :error}
      _ -> {:ok, :ok}
    end
  end
end
