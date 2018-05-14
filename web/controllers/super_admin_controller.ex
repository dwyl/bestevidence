defmodule Bep.SuperAdminController do
  use Bep.Web, :controller
  alias Bep.Client

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def new(conn, _params) do
    changeset = Client.changeset(%Client{})
    render(conn, "new.html", changeset: changeset)
  end
end
