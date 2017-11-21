defmodule Bep.UserControllerTest do
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

  @tag login_as: %{email: "email@example.com"}
  test "/login :: delete", %{conn: conn, user: user} do
    conn = delete conn, user_path(conn, :delete, user)
    assert redirected_to(conn) == page_path(conn, :index)
  end

  @tag login_as: %{email: "email@example.com"}
  test "/update types for user", %{conn: conn, user: user} do
    insert_types()
    conn = put conn, user_path(conn, :update, user, %{"types": %{"1": "true", "2": "true"}})
    assert redirected_to(conn) == page_path(conn, :index)
  end
end
