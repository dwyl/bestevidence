defmodule Bep.ComponentHelpersTest do
  use Bep.ConnCase, async: true
  alias Bep.{Client, ComponentHelpers}

  setup %{conn: conn} do
    ca = insert_user("client-admin")
    conn = assign(conn, :current_user, ca)

    {:ok, conn: conn}
  end

  test "msg_link_path returns the correct path", %{conn: conn} do
    path = ComponentHelpers.msg_link_path(conn)
    assert path == "/list-users"
  end

  test "about_path_for_reg_or_cli returns correct paths", %{conn: conn} do
    client = Repo.get_by(Client, name: "default")
    client_conn = assign(conn, :client, client)
    client_path = ComponentHelpers.about_path_for_reg_or_cli(client_conn)

    new_client = insert_client(%{name: "new_cli", slug: "new_cli"})
    new_cli_conn = assign(conn, :client, new_client)
    new_cli_path = ComponentHelpers.about_path_for_reg_or_cli(new_cli_conn)

    assert client_path == "/about"
    assert new_cli_path == "/new_cli/about"
  end

  test "reg_user? returns false if user is client admin", %{conn: conn} do
    assert ComponentHelpers.reg_user?(conn) == false
  end
end
