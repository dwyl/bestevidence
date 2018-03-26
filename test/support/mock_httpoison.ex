defmodule Bep.Mock.HTTPoison do
  @moduledoc false

  def request("post", _url, _body, _headers) do
    %{status_code: 200}
  end
end
