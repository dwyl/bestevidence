defmodule Bep.AuthTest do
  use Bep.ConnCase
  alias Bep.{Auth, Router, User}

  describe "testing authenticate_client" do
    setup %{conn: conn} do
      insert_client()
      {:ok, %{conn: conn}}
    end

    test "authenticate_client halts when client is not in db" do
      conn = get(build_conn(), "wrongClient")
      assert conn.halted
    end

    test "authenticate_client continues when client is in db" do
      conn = get(build_conn(), "testClient")
      refute conn.halted
    end
  end

  setup %{conn: conn} do

    conn =
      conn
      |> bypass_through(Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  test "Auth init function", do: assert Auth.init([repo: 1])

  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])

    assert conn.halted
  end

  test "authenticate_user continues when the current_user exists", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %User{})
      |> Auth.authenticate_user([])

    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    login_conn =
      conn
      |> Auth.login(%User{id: 123})
      |> send_resp(:ok, "")
    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == 123
  end

  test "call with no session sets current_user assign to nil", %{conn: conn} do
    conn = Auth.call(conn, Repo)
    assert conn.assigns.current_user == nil
  end

  test "login with a not found user", %{conn: conn} do
    assert {:error, :not_found, _conn} =
      Auth.login_by_email_and_pass(conn, "nouser@example.com", "secret", repo: Repo)
  end

  test "logout drops the session", %{conn: conn} do
    logout_conn =
      conn
      |> put_session(:user_id, 123)
      |> Auth.logout()
      |> send_resp(:ok, "")

    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id)
  end

end
