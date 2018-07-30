defmodule Bep.BearController do
  use Bep.Web, :controller

  def paper_details(conn, params) do
    render(conn, :paper_details)
  end
end
