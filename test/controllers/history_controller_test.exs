defmodule Bep.HistoryControllerTest do
  use Bep.ConnCase
  setup %{conn: conn} = config do
    if user = config[:login_as] do
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "GET /history - redirect if not logged in", %{conn: conn} do
    conn = get conn, "/history"
    assert html_response(conn, 302)
  end

  @tag login_as: %{email: "email@example.com", id: 1}
  test "GET /history - logged in", %{conn: conn} do
    conn = get conn, "/history"
    assert html_response(conn, 200)
  end
end
