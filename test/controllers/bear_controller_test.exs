defmodule Bep.BearControllerTest do
  use Bep.ConnCase
  alias Bep.{BearQuestions, Repo}

  describe "Testing pico search controller" do
    setup %{conn: conn} do
      user = insert_user()
      inserted_search = insert_search(user)
      pub = insert_publication(inserted_search)

      conn =
        conn
        |> assign(:current_user, user)
        |> assign_message()

      {:ok, conn: conn, pub: pub}
    end

    test "GET /paper-details", %{conn: conn, pub: pub} do
      path = bear_path(conn, :paper_details, publication_id: pub.id)
      conn = get(conn, path)
      assert html_response(conn, 200) =~ "Paper details"
    end

    test "GET /check-validity", %{conn: conn} do
      insert_bear_questions("bear question?")
      path = bear_path(conn, :check_validity)
      conn = get(conn, path)
      assert html_response(conn, 200) =~ "Check validity"
    end

    test "GET /calculate-results", %{conn: conn} do
      path = bear_path(conn, :calculate_results)
      conn = get(conn, path)
      assert html_response(conn, 200) =~ "Calculate results"
    end

    test "GET /Relevance", %{conn: conn} do
      path = bear_path(conn, :relevance)
      conn = get(conn, path)
      assert html_response(conn, 200) =~ "Relevance"
    end

    test "POST /bear-form from /paper-details", %{conn: conn, pub: pub} do
      path = bear_path(conn, :create)
      conn = post(conn, path, %{pub_id: pub.id, next: "check_validity"})
      assert html_response(conn, 302)
    end

    test "POST /bear-form from check_validity", %{conn: conn} do
      path = bear_path(conn, :create)
      conn = post(conn, path, %{next: "calculate_results"})
      assert html_response(conn, 302)
    end

    test "POST /bear-form from calculate_results", %{conn: conn} do
      path = bear_path(conn, :create)
      conn = post(conn, path, %{next: "relevance"})
      assert html_response(conn, 302)
    end

    test "POST /bear-form from relevance", %{conn: conn} do
      path = bear_path(conn, :create)
      conn = post(conn, path, %{next: "complete_bear"})
      assert html_response(conn, 302)
    end

    test "POST /bear-form save and continue later", %{conn: conn, pub: pub} do
      path = bear_path(conn, :create)
      conn = post(conn, path, %{pub_id: pub.id})
      assert html_response(conn, 302)
    end
  end
end
