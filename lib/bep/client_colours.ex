defmodule Bep.ClientColours do
  @moduledoc false

  def get_client_colour(conn, key) do
    Map.get(conn.assigns.client, key)
  end
end
