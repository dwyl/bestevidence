defmodule Bep.Tripdatabase.HTTPClient do
  @moduledoc """
  Wrapper functions for the Tripdatabase API
  """
  alias Poison.Parser
  @key Application.get_env(:bep, :tripdatabase_key)
  @api_url "https://www.tripdatabase.com"

  def search(query, skip \\ 0) do
    url = "#{@api_url}/search/json?key=#{@key}&criteria=" <> URI.encode(query) <> "&skip=#{skip}"
    {:ok, res} = HTTPoison.get(url, [], [ssl: [{:versions, [:'tlsv1.2']}]])
    # the api return byte order mark: "﻿{\"total\":6767}"
    {:ok, _data} = Parser.parse String.slice(res.body, 1..-1)
  end
end
