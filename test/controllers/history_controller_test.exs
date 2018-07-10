defmodule Bep.HistoryControllerTest do
  use Bep.ConnCase

  test "GET /history - redirect if not logged in", %{conn: conn} do
    conn = get conn, "/history"
    assert html_response(conn, 302)
  end

  test "GET /history - logged in", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> assign(:current_user, user)
      |> assign_message()

    conn = get conn, "/history"
    assert html_response(conn, 200)
  end
end
