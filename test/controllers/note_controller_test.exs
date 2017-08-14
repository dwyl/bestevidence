defmodule Bep.NoteControllerTest do
  use Bep.ConnCase
  setup %{conn: conn} = config do
    if user = config[:login_as] do
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  @tag login_as: %{email: "email@example.com"}
  test "GET /notes", %{conn: conn} do
    conn = get conn, "/notes"
    assert html_response(conn, 200) =~ "All Notes"
  end

  test "GET /notes redirect to / when not logged in", %{conn: conn} do
    conn = get conn, "/notes"
    assert html_response(conn, 302)
  end
end
