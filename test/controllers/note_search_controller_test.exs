defmodule Bep.NoteSearchControllerTest do
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

  test "requires user authentication notes action", %{conn: conn} do
    Enum.each([
      get(conn, note_search_path(conn, :create)),
      get(conn, note_search_path(conn, :edit, 1))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: %{email: "email@example.com"}
  test "GET /note/search new", %{conn: conn, user: user} do
    search = insert_search(user)
    conn = get conn, note_search_path(conn, :new, search_id: search.id)
    assert html_response(conn, 200)
  end

  @tag login_as: %{email: "email@example.com"}
  test "POST /note/search create", %{conn: conn, user: user} do
    search = insert_search(user)
    conn = post conn, note_search_path(
      conn,
      :create,
      %{"note_search" => %{"note" => "test note", "search_id" => search.id}}
    )
    assert html_response(conn, 302)
  end

  @tag login_as: %{email: "email@example.com"}
  test "GET /note/search edit", %{conn: conn, user: user} do
    search = insert_search(user)
    note = insert_note(search)
    conn = get conn, note_search_path(conn, :edit, note, search_id: search.id)
    assert html_response(conn, 200)
  end

  @tag login_as: %{email: "email@example.com"}
  test "PUT /note/search update", %{conn: conn, user: user} do
    search = insert_search(user)
    note = insert_note(search)
    conn = put conn, note_search_path(
      conn,
      :update,
      note,
      %{
        "id" => note.id,
        "note_search" => %{"note" => "updated note", "search_id" => search.id}
      }
      )
    assert html_response(conn, 302)
  end

end
