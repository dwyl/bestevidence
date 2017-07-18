defmodule Bep.PageController do
  use Bep.Web, :controller

  def index(conn, _params) do
    if conn.assigns.current_user do
      redirect(conn, to: search_path(conn, :index))
    else
      render conn, "index.html"
    end
  end
end
