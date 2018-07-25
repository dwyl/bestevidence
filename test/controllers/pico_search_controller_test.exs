defmodule Bep.PicoSearchControllerTest do
  use Bep.ConnCase
  @pico_search %{pico_search: %{
    note_id: "37",
    p: "",
    i: "",
    c: "",
    probability: "",
    current_position: "",
    outcome_benefit_1: "true",
    outcome_index_1: "1",
    outcome_input_1: ""
}}

  describe "Testing pico search controller" do
    setup %{conn: conn} do
      user = insert_user()
      inserted_search = insert_search(user, true)
      note_search = insert_note(inserted_search)
      conn =
        assign(conn, :current_user, user)
        |> assign_message()

      {:ok, conn: conn, search: inserted_search, note_search: note_search}
    end

    test "GET pico/new", %{conn: conn, search: search, note_search: note_search} do
      assigns = [note_id: note_search.id, search_id: search.id]
      path = pico_search_path(conn, :new, assigns)
      conn = get(conn, path)
      assert html_response(conn, 200) =~ "Structure the uncertainty"
    end

    test "GET pico/edit", %{conn: conn, search: search, note_search: note_search} do
      pico_search = insert_pico_search(note_search)
      assigns = [note_id: note_search.id, search_id: search.id]
      path = pico_search_path(conn, :edit, pico_search.id, assigns)
      conn = get(conn, path)
      assert html_response(conn, 200) =~ "Structure the uncertainty"
    end

    test "POST pico/create without pico outcome", %{conn: conn} do
      path = pico_search_path(conn, :create)
      conn = post(conn, path, @pico_search)
      assert html_response(conn, 302)
    end

    test "POST pico/create with pico outcome", %{conn: conn} do
      path = pico_search_path(conn, :create)
      pico_search =
        @pico_search
        |> Map.update!(:pico_search, &Map.put(&1, :outcome_input_1, "outcome"))
        |> Map.update!(:pico_search, &Map.put(&1, :probability, "50%"))
      conn = post(conn, path, pico_search)
      assert html_response(conn, 302)
    end

    test "POST pico/create with pico outcome that has no %", %{conn: conn} do
      path = pico_search_path(conn, :create)
      pico_search =
        @pico_search
        |> Map.update!(:pico_search, &Map.put(&1, :probability, "50"))
      conn = post(conn, path, pico_search)
      assert html_response(conn, 302)
    end
  end
end
