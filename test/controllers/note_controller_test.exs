defmodule Bep.NoteControllerTest do
  use Bep.ConnCase

  setup %{conn: conn} = config do
    if config[:login_as] do
      user = insert_user()
      conn =
        conn
        |> assign(:current_user, user)
        |> assign_message()
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  @tag login_as: %{email: "email@example.com"}
  test "GET /notes", %{conn: conn} do
    conn = get conn, "/notes"
    assert html_response(conn, 200) =~ "Notes"
  end

  test "GET /notes redirect to / when not logged in", %{conn: conn} do
    conn = get conn, "/notes"
    assert html_response(conn, 302)
  end
end
