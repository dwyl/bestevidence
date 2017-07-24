defmodule Bep.SearchControllerTest do
  use Bep.ConnCase

  setup %{conn: conn} = config do
    if config[:login_as] do
      user = insert_user()
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "requires user authentication on index and new actions", %{conn: conn} do
    Enum.each([
      get(conn, search_path(conn, :index)),
      get(conn, search_path(conn, :create))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: %{email: "email@example.com"}
  test "logged in user can access the search actions index", %{conn: conn, user: _user} do
    conn = get conn, search_path(conn, :index)
    assert html_response(conn, 200)
  end

  @tag login_as: %{email: "email@example.com"}
  test "empty search redirect to search page with a warning", %{conn: conn, user: _user} do
    conn = post conn, search_path(conn, :create, %{"search" => %{"term": ""}})
    assert html_response(conn, 302)
  end

  @tag login_as: %{email: "email@example.com"}
  test "search evidences linked to water", %{conn: conn, user: _user} do
    conn = post conn, search_path(conn, :create, %{"search" => %{"term": "water"}})
    assert html_response(conn, 200) =~ "Results"
  end
end
