defmodule Bep.Tripdatabase.HTTPClient do
  def search(query) do
    url = "https://www.tripdatabase.com/search/json?criteria=" <> URI.encode(query)
    {:ok, res} = HTTPoison.get(url, [], [ ssl: [{:versions, [:'tlsv1.2']}] ])
    # the api return byte order mark: "﻿{\"total\":6767}"
    {:ok, data} = Poison.Parser.parse String.slice(res.body, 1..-1)
  end
end