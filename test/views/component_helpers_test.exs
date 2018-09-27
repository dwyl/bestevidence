defmodule Bep.ComponentHelpersTest do
  use Bep.ConnCase, async: true
  alias Bep.ComponentHelpers

  setup %{conn: conn} do
    ca = insert_user("client-admin")
    conn = assign(conn, :current_user, ca)

    {:ok, conn: conn}
  end

  test "msg_link_path returns the correct path", %{conn: conn} do
    path = ComponentHelpers.msg_link_path(conn)
    assert path == "/list-users"
  end

  test "reg_user? returns false if user is client admin", %{conn: conn} do
    assert ComponentHelpers.reg_user?(conn) == false
  end
end
