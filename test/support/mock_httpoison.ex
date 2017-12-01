defmodule Bep.Mock.HTTPoison do
  def request("post", _url, _body, _headers) do
    %{status_code: 200}
  end
end
