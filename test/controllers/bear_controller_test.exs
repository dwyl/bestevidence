defmodule Bep.BearControllerTest do
  use Bep.ConnCase
  alias Bep.{BearQuestion}

  describe "Testing pico search controller" do
    setup %{conn: conn} do
      user = insert_user()
      search = insert_search(user)
      pub = insert_publication(search)

      pico_search =
        search
        |> insert_note()
        |> insert_pico_search()

      params = %{
        pub_id: pub.id,
        next: "check_validity",
        pico_search_id: pico_search.id,
        q_1: "answer"
      }

      conn =
        conn
        |> assign(:current_user, user)
        |> assign_message()

      {
        :ok, conn: conn, pub: pub, user: user, params: params,
        pico_search: pico_search
      }
    end

    test "GET /paper-details", %{conn: conn, pub: pub} do
      assigns = [publication_id: pub.id, pico_search_id: 1]
      path = bear_path(conn, :paper_details, assigns)
      conn = get(conn, path)
      assert html_response(conn, 200) =~ "Paper details"
    end

    test "GET /check-validity", %{conn: conn, pub: pub, pico_search: ps} do
      q_list = BearQuestion.check_validity_questions()
      questions = insert_bear_questions("check_validity", q_list)
      in_light_question = Enum.find(questions, &(&1.question =~ "In light"))
      insert_pico_outcomes(ps)
      insert_bear_answer(in_light_question, pub, ps, %{index: 1, answer: "blah"})

      assigns = [publication_id: pub.id, pico_search_id: ps.id]
      path = bear_path(conn, :check_validity, assigns)
      conn = get(conn, path)
      assert html_response(conn, 200) =~ "Check validity"
    end

    test "GET /calculate-results", %{conn: conn} do
      path = bear_path(conn, :calculate_results)
      conn = get(conn, path)
      assert html_response(conn, 200) =~ "Calculate results"
    end

    test "GET /Relevance", %{conn: conn} do
      q_list = BearQuestion.relevance_questions()
      insert_bear_questions("relevance", q_list)
      path = bear_path(conn, :relevance)
      conn = get(conn, path)
      assert html_response(conn, 200) =~ "Relevance"
    end

    test "POST /bear-form from /paper-details", %{conn: conn, params: params} do
      path = bear_path(conn, :create)
      conn = post(conn, path, params)
      assert html_response(conn, 302)
    end

    test "POST /bear-form from check_validity", %{conn: conn, params: params} do
      params =
        params
        |> Map.put(:next, "calculate_results")
        |> Map.put("q_1_o_index_1", "calculate_results")
      path = bear_path(conn, :create)
      conn = post(conn, path, params)
      assert html_response(conn, 302)
    end

    test "POST /bear-form from calculate_results", %{conn: conn, params: params} do
      params = Map.put(params, :next, "relevance")
      path = bear_path(conn, :create)
      conn = post(conn, path, params)
      assert html_response(conn, 302)
    end

    test "POST /bear-form from relevance", %{conn: conn, params: params} do
      params = Map.put(params, :next, "complete_bear")
      path = bear_path(conn, :create)
      conn = post(conn, path, params)
      assert html_response(conn, 302)
    end

    test "POST /bear-form save and continue later", %{conn: conn, pub: pub, pico_search: ps} do
      path = bear_path(conn, :create)
      conn = post(conn, path, %{pub_id: pub.id, pico_search_id: ps.id})
      assert html_response(conn, 302)
    end
  end
end
