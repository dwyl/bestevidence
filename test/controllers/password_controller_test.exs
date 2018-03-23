defmodule Bep.PasswordControllerTest do
  use Bep.ConnCase
  alias Bep.{Repo, User, PasswordReset, PasswordController}

  setup %{conn: conn} do
    %User{}
    |> User.registration_changeset(%{email: "test@test.com", password: "password"})
    |> Repo.insert

    {:ok, conn: conn}
  end

  test "GET /password", %{conn: conn} do
    conn = get conn, "/password"
    assert html_response(conn, 200) =~ "Forgotten Your Password?"
  end

  test "request reset", %{conn: _conn} do
    assert {:ok, token} = PasswordController.gen_token("test@test.com")
    assert Repo.get_by(PasswordReset, token: token)
  end

  test "POST password/request", %{conn: conn} do
    email = System.get_env("SES_EMAIL")
    conn = post conn, "/password/request", %{"email" => %{"email" => email}}
    assert html_response(conn, 200)
    assert get_flash(conn, :info) =~ "We've sent a password reset link"
  end

  test "POST password/request - bad user", %{conn: conn} do
    conn = post conn, "/password/request", %{"email" => %{"email" => "nonuser@test.com"}}
    assert html_response(conn, 200)
    assert get_flash(conn, :info) =~ "We've sent a password reset link"
  end

  test "GET /password/reset", %{conn: conn} do
    conn = get conn, "/password/reset", %{"token" => "test"}
    assert html_response(conn, 200) =~ "Reset Your Password"
  end

  test "POST /password/reset", %{conn: conn} do
    {:ok, token} = PasswordController.gen_token("test@test.com")
    conn = post conn, "/password/reset", %{"reset" => %{"token" => token, "email" => "test@test.com", "password" => "password"}}
    assert html_response(conn, 200)
    assert get_flash(conn, :info) =~ "Your password has been updated"
  end

  test "POST /password/reset - bad token", %{conn: conn} do
    conn = post conn, "/password/reset", %{"reset" => %{"token" => "token", "email" => "test@test.com", "password" => "password"}}
    assert html_response(conn, 200)
    assert get_flash(conn, :error) =~ "This password reset link has expired."
  end

  test "POST /password/reset - bad user", %{conn: conn} do
    {:ok, token} = PasswordController.gen_token("test@test.com")
    conn = post conn, "/password/reset", %{"reset" => %{"token" => token, "email" => "baduser@test.com", "password" => "password"}}
    assert html_response(conn, 200)
    assert get_flash(conn, :error) =~ "This password reset link has expired."
  end

  test "POST /password/reset - expired token", %{conn: conn} do
    {:ok, token} = PasswordController.gen_token("test@test.com")

      Repo.get_by(PasswordReset, token: token)
      |> PasswordReset.changeset(%{})
      |> put_change(:token_expires, Timex.shift(Timex.now, hours: -2))
      |> Repo.update

    conn = post conn, "/password/reset", %{"reset" => %{"token" => token, "email" => "test@test.com", "password" => "password"}}
    assert html_response(conn, 200)
    assert get_flash(conn, :error) =~ "This password reset link has expired."
  end
end
