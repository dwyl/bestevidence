defmodule Bep.NotePublicationControllerTest do
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
      get(conn, note_publication_path(conn, :create)),
      get(conn, note_publication_path(conn, :edit, 1))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: %{email: "email@example.com"}
  test "GET /note/publication new", %{conn: conn, user: user} do
    search = insert_search(user)
    publication = insert_publication(search)
    conn = get conn, note_publication_path(
      conn,
      :new, publication_id: publication.id
    )
    assert html_response(conn, 200)
  end

  @tag login_as: %{email: "email@example.com"}
  test "POST /note/publication create", %{conn: conn, user: user} do
    search = insert_search(user)
    publication = insert_publication(search)
    conn = post conn, note_publication_path(
      conn,
      :create,
      %{"note_publication" => %{
          "note" => "test note",
          "user_id" => user.id,
          "publication_id" => publication.id}
        }
    )
    assert html_response(conn, 302)
  end

  @tag login_as: %{email: "email@example.com"}
  test "GET /note/search edit", %{conn: conn, user: user} do
    search = insert_search(user)
    publication = insert_publication(search)
    note = insert_note_publication(publication, user)
    conn = get conn, note_publication_path(
      conn,
      :edit,
      note,
      publication_id: publication.id
    )
    assert html_response(conn, 200)
  end

  @tag login_as: %{email: "email@example.com"}
  test "PUT /note/publication update", %{conn: conn, user: user} do
    search = insert_search(user)
    publication = insert_publication(search)
    note = insert_note_publication(publication, user)
    conn = put conn, note_publication_path(
      conn,
      :update,
      note,
      %{
        "id" => note.id,
        "note_publication" => %{
          "note" => "test note updated",
          "user_id" => user.id,
          "publication_id" => publication.id}
        }
      )
    assert html_response(conn, 302)
  end

end
