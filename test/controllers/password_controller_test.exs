defmodule Bep.PasswordControllerTest do
  use Bep.ConnCase
  alias Bep.{Repo, User, PasswordReset, PasswordController}

  describe "user is logged in" do
    setup %{conn: conn} do
      user = insert_user()
      conn =
        conn
        |> assign(:current_user, user)
        |> assign_message

      {:ok, conn: conn}
    end

    test "GET /password/change - logged in", %{conn: conn} do
      conn = get conn, "/password/change"
      assert html_response(conn, 200)
    end

    test "POST /password/change - password changed", %{conn: conn} do
      pass_map = change_password_map("supersecret", "newsecret", "newsecret")
      conn = post conn, "password/change", pass_map
      assert html_response(conn, 200)
      assert get_flash(conn, :info) =~ "Password updated"
    end

    test "POST /password/change - password too short and passwords don't match", %{conn: conn} do
      err_str = "Passwords do not match and password should be at least 6 characters"
      pass_map = change_password_map("supersecret", "test", "tes")
      conn = post conn, "password/change", pass_map
      assert html_response(conn, 200)
      assert get_flash(conn, :error) =~ err_str
    end

    test "POST /password/change - password cannot be empty", %{conn: conn} do
      pass_map = change_password_map("supersecret", "", "")
      conn = post conn, "password/change", pass_map
      assert html_response(conn, 200)
      assert get_flash(conn, :error) =~ "Password can't be blank"
    end

    test "POST /password/change - passwords do not match", %{conn: conn} do
      pass_map = change_password_map("supersecret", "newsecret", "doesntmatch")
      conn = post conn, "password/change", pass_map
      assert html_response(conn, 200)
      assert get_flash(conn, :error) =~ "Passwords do not match"
    end

    test "POST /password/change - incorrect current password", %{conn: conn} do
      pass_map = change_password_map("incorrectpassword", "newsecret", "newsecret")
      conn = post conn, "password/change", pass_map
      assert html_response(conn, 200)
      assert get_flash(conn, :error) =~ "Incorrect password"
    end
  end

  setup %{conn: conn} do
    %User{}
    |> User.registration_changeset(%{email: "success@simulator.amazonses.com", password: "password"})
    |> Repo.insert

    {:ok, conn: conn}
  end

  test "GET /password/change - redirects if user is not logged in", %{conn: conn} do
    conn = get conn, "/password/change"
    assert html_response(conn, 302)
  end

  test "GET /password", %{conn: conn} do
    conn = get conn, "/password"
    assert html_response(conn, 200) =~ "Forgotten Your Password?"
  end

  test "request reset", %{conn: _conn} do
    assert {:ok, token} = PasswordController.gen_token("success@simulator.amazonses.com")
    assert Repo.get_by(PasswordReset, token: token)
  end

  test "POST password/request", %{conn: conn} do
    conn = post conn, "/password/request", %{"email" => %{"email" => "success@simulator.amazonses.com"}}
    assert html_response(conn, 200)
    assert get_flash(conn, :info) =~ "We've sent a password reset link"
  end

  test "POST :client_slug/password/request", %{conn: conn} do
    insert_user()
    conn =
      post(
        conn,
        client_slug_password_path(conn, :request, "testslug"),
        email: %{"email" => "email@example.com"}
      )
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
    {:ok, token} = PasswordController.gen_token("success@simulator.amazonses.com")
    conn = post conn, "/password/reset", %{"reset" => %{"token" => token, "email" => "success@simulator.amazonses.com", "password" => "password", "password_confirmation" => "password"}}
    assert html_response(conn, 200)
    assert get_flash(conn, :info) =~ "Your password has been updated"
  end

  test "POST /password/reset - passwords do not match", %{conn: conn} do
    {:ok, token} = PasswordController.gen_token("success@simulator.amazonses.com")
    conn = post conn, "/password/reset", %{"reset" => %{"token" => token, "email" => "success@simulator.amazonses.com", "password" => "password", "password_confirmation" => "something_else"}}
    assert html_response(conn, 200)
    assert get_flash(conn, :error) =~ "Passwords do not match"
  end

  test "POST /password/reset - bad token", %{conn: conn} do
    conn = post conn, "/password/reset", %{"reset" => %{"token" => "token", "email" => "success@simulator.amazonses.com", "password" => "password", "password_confirmation" => "password"}}
    assert html_response(conn, 200)
    assert get_flash(conn, :error) =~ "This password reset link has expired."
  end

  test "POST /password/reset - bad user", %{conn: conn} do
    {:ok, token} = PasswordController.gen_token("success@simulator.amazonses.com")
    conn = post conn, "/password/reset", %{"reset" => %{"token" => token, "email" => "baduser@test.com", "password" => "password", "password_confirmation" => "password"}}
    assert html_response(conn, 200)
    assert get_flash(conn, :error) =~ "This link is not valid for the given email address."
  end

  test "POST /password/reset - expired token", %{conn: conn} do
    {:ok, token} = PasswordController.gen_token("success@simulator.amazonses.com")

      PasswordReset
      |> Repo.get_by(token: token)
      |> PasswordReset.changeset(%{})
      |> put_change(:token_expires, Timex.shift(Timex.now, hours: -2))
      |> Repo.update

    conn = post conn, "/password/reset", %{"reset" => %{"token" => token, "email" => "success@simulator.amazonses.com", "password" => "password", "password_confirmation" => "password"}}
    assert html_response(conn, 200)
    assert get_flash(conn, :error) =~ "This password reset link has expired."
  end
end
