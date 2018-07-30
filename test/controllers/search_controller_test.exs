defmodule Bep.SearchControllerTest do
  use Bep.ConnCase
  alias Bep.{NoteSearch, Repo}
  @uncertainty %{
    search: %{term: ""},
    question_type: "uncertainty"
  }

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

  test "requires user authentication on index and new actions", %{conn: conn} do
    Enum.each([
      get(conn, search_path(conn, :index)),
      get(conn, search_path(conn, :create))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: %{email: "email@example.com"}
  test "logged in user can access the search actions index", %{conn: conn, user: _user} do
    conn = get conn, search_path(conn, :index)
    assert html_response(conn, 200)
  end

  @tag login_as: %{email: "email@example.com"}
  test "empty search redirect to search page with a warning", %{conn: conn, user: _user} do
    conn = post conn, search_path(conn, :create, @uncertainty)
    assert html_response(conn, 302)
  end

  @tag login_as: %{email: "email@example.com"}
  test "collect uncertainty is pressed and redirects to note page", %{conn: conn} do
    search = Map.put(@uncertainty, :search, %{term: "some search"})
    conn = post conn, search_path(conn, :create, search)
    assert html_response(conn, 302)
  end

  @tag login_as: %{email: "email@example.com"}
  test "collect uncertainty is pressed and redirects to note page when uncertainty exists", %{conn: conn, user: user} do
    insert_search(user)
    search = Map.put(@uncertainty, :search, %{term: "search test"})
    conn = post conn, search_path(conn, :create, search)
    assert html_response(conn, 302)
  end

  @tag login_as: %{email: "email@example.com"}
  test "collect uncertainty is pressed and redirects to edit note page when uncertainty and note exist", %{conn: conn, user: user} do
    inserted_search = insert_search(user)
    Repo.insert!(%NoteSearch{note: "test note", search_id: inserted_search.id})
    search = Map.put(@uncertainty, :search, %{term: "search test"})
    conn = post conn, search_path(conn, :create, search)
    assert html_response(conn, 302)
  end

  @tag login_as: %{email: "email@example.com"}
  test "search evidences linked to water", %{conn: conn, user: _user} do
    conn = post conn, search_path(conn, :create, %{"search" => %{"term": "water"}})
    assert html_response(conn, 200) =~ "Results"
  end

  @tag login_as: %{email: "email@example.com"}
  test "search evidences filter", %{conn: conn, user: user} do
    search = insert_search(user)
    search_map = %{"search" => %{"term": "water", search_id: search.id}}
    conn = post conn, search_path(conn, :filter, search_map)
    assert html_response(conn, 200) =~ "Results"
  end

  @tag login_as: %{email: "email@example.com"}
  test "search with the same term", %{conn: conn, user: user} do
    insert_search(user)
    conn = post conn, search_path(conn, :create, %{"search" => %{"term": "search test"}})
    assert html_response(conn, 200) =~ "Results"
  end

  @tag login_as: %{email: "email@example.com"}
  test "search with the term breaking Tripdatabase", %{conn: conn, user: user} do
    insert_search(user)
    term =
    """
      this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search
    """
    conn = post conn, search_path(conn, :create, %{"search" => %{"term": term}})
    assert html_response(conn, 200) =~ "Results"
  end

  @tag login_as: %{email: "email@example.com"}
  test "search evidences filter with a too long term", %{conn: conn, user: user} do
    search = insert_search(user)
    term = """
    this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search this is a very long search
    """
    search_map = %{"search" => %{"term": term, search_id: search.id}}
    conn = post conn, search_path(conn, :filter, search_map)
    assert html_response(conn, 200) =~ "Results"
  end

  @tag login_as: %{email: "email@example.com"}
  test "Filtering by category", %{conn: conn, user: user} do
    search = insert_search(user)
    search_params_1 = %{"term": "test", search_id: search.id}
    search_params_2 = %{"term": "test", "category": "34", search_id: search.id}

    conn_1 = post conn, search_path(conn, :filter, %{"search" => search_params_1})
    conn_2 = post conn, search_path(conn, :filter, %{"search" => search_params_2})

    assert html_response(conn_1, 200) != html_response(conn_2, 200)
  end

end
