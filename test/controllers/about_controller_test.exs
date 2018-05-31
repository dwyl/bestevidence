defmodule Bep.AboutControllerTest do
  use Bep.ConnCase
  alias Plug.Conn

  test "GET /about", %{conn: conn} do
    conn = get conn, "/about"
    assert html_response(conn, 200) =~ "About BestEvidence"
  end

  test "GET /about with client", %{conn: conn} do
    conn =
      conn
      |> Conn.assign(:client, %{slug: "test", about_text: ""})
      |> get("/about")

    assert html_response(conn, 200) =~ "About BestEvidence"
  end
end
