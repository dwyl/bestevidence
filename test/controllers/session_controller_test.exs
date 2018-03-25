defmodule Bep.SessionControllerTest do
  use Bep.ConnCase

  test "GET /sessions/new", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "If you are on a public computer, remember to log out."
  end

  test "POST /sessions/new", %{conn: conn} do
    session =
      %{"session" =>
        %{"email" => "email@example.com", "password" => "password"}
      }
    conn = post conn, session_path(conn, :create, session)
    assert html_response(conn, 200)
  end
end
