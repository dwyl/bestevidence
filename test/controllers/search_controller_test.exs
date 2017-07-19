defmodule Bep.SearchControllerTest do
  use Bep.ConnCase

  setup %{conn: conn} = config do
    if user = config[:login_as] do
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "requires user authentication on index and new actions", %{conn: conn} do
    Enum.each([
      get(conn, search_path(conn, :index)),
      get(conn, search_path(conn, :new))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: %{email: "email@example.com"}
  test "logged in user can access the search actions index and new", %{conn: conn, user: _user} do
    conn = get conn, search_path(conn, :index)
    assert html_response(conn, 200)
  end
end
