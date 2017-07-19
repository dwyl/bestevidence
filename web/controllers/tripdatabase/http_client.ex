defmodule Bep.Tripdatabase.HTTPClient do
  @moduledoc """
  Wrapper functions for the Tripdatabase API
  """
  alias Poison.Parser

  def search(query) do
    url = "https://www.tripdatabase.com/search/json?criteria=" <> URI.encode(query)
    {:ok, res} = HTTPoison.get(url, [], [ssl: [{:versions, [:'tlsv1.2']}]])
    # the api return byte order mark: "﻿{\"total\":6767}"
    {:ok, _data} = Parser.parse String.slice(res.body, 1..-1)
  end
end
