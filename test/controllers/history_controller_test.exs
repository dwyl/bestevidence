defmodule Bep.HistoryControllerTest do
  use Bep.ConnCase

  test "GET /history - redirect if not logged in", %{conn: conn} do
    conn = get conn, "/history"
    assert html_response(conn, 302)
  end

  test "GET /history - logged in", %{conn: conn} do
    user = insert_user()
    conn = assign(conn, :current_user, user)
    conn = get conn, "/history"
    assert html_response(conn, 200)
  end
end
