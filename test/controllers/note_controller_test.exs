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
    assert html_response(conn, 200) =~ "BEARs"
  end

  test "GET /notes redirect to / when not logged in", %{conn: conn} do
    conn = get conn, "/notes"
    assert html_response(conn, 302)
  end

  @tag login_as: %{email: "email@example.com"}
  test "GET /notes when user has started a BEAR", %{conn: conn, user: user} do
    search = insert_search(user, true)
    note_search = insert_note(search)
    insert_pico_search(note_search)
    insert_publication(search)
    conn = get conn, "/notes"

    assert html_response(conn, 200) =~ "BEARs"
  end
end
