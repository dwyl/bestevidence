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

  test "to_client_or_all returns true with SA or client id of CA", %{conn: conn} do
    current_user = conn.assigns.current_user
    client_id = ComponentHelpers.to_client_or_all(conn)
    assert client_id == [to_client: current_user.client_id]
  end
end
