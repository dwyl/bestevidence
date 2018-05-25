defmodule Bep.Mock.ExAws do
  @moduledoc false
  def request(_op) do
    {:ok, :ok}
  end
end
