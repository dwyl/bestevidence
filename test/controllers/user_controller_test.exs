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

  test "GET /users/new", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "Great. Let's get started."
  end

  test "POST /users/create redirect to /login when email already linked to an account", %{conn: conn} do
    insert_user()
    conn = post conn, user_path(conn, :create, %{"user" => %{"email": "email@example.com", "password": "supersecret"}})
    assert html_response(conn, 302)
  end

  test "POST /users/create show /user/new when password is too short", %{conn: conn} do
    conn = post conn, user_path(conn, :create, %{"user" => %{"email": "new@example.com", "password": "1"}})
    assert html_response(conn, 200)
  end

  test "POST /users/create", %{conn: conn} do
    insert_types()
    conn = post conn, user_path(conn, :create, %{"user" => %{
      "email": "new-email@example.com",
      "password": "supersecret"}
    })
    assert html_response(conn, 302)
  end

  test "POST /:client_slug/users/create", %{conn: conn} do
    client = insert_client()
    conn =
      post conn, client_slug_user_path(conn, :create, client.slug,  %{"user" => %{
        "email": "new-email@example.com",
        "password": "supersecret"}
      })
    assert html_response(conn, 302)
  end
end
