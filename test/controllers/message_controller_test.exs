defmodule Bep.MessageControllerTest do
  use Bep.ConnCase

  test "GET /message gets redirected when not logged in", %{conn: conn} do
    conn = get(conn, "message")
    assert html_response(conn, 302)
  end

  test "GET /message as a regular user gets client view", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, insert_user())
      |> get("/message")

    assert html_response(conn, 200) =~ "user chat"
  end

  test "GET /message as an admin user gets client view", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, insert_user("super-admin"))
      |> get("/super-admin/message")

    assert html_response(conn, 200) =~ "admin chat"
  end
end
