defmodule MessagesControllerTest do
  use Bep.ConnCase

  describe "Testing Message controller as standard user" do
    setup %{conn: conn} do
      user = insert_user()
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    test "GET /messages?user=user_id", %{conn: conn, user: user} do
      conn = get(conn, "/messages?user=#{user.id}")
      assert html_response(conn, 200)
    end
  end

  describe "Testing Message controller as SA" do
    setup %{conn: conn} do
      user = insert_user("doctor", %{email: "test@user.com"})
      sa = insert_user("super-admin")
      conn = assign(conn, :current_user, sa)

      {:ok, conn: conn, user: user, sa: sa}
    end

    test "GET /super-admin/messages?user=user_id", %{conn: conn, user: user} do
      conn = get(conn, "/super-admin/messages?user=#{user.id}")
      assert html_response(conn, 200)
    end
  end
end
