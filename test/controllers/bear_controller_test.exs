defmodule Bep.BearControllerTest do
  use Bep.ConnCase
  alias Bep.{BearAnswers, BearQuestion}

  describe "Testing bear controller" do
    setup %{conn: conn} do
      user = insert_user()
      search = insert_search(user)
      pub = insert_publication(search)

      pico_search =
        search
        |> insert_note()
        |> insert_pico_search()

      params = %{
        bear_answers: %{
          pub_id: pub.id,
          pico_search_id: pico_search.id,
          q_1: "answer",
          q_2_o_index_1: "answer"
        },
        next: "check_validity",
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

    test "GET /bear-complete", %{conn: conn} do
      path = bear_path(conn, :complete)
      conn = get(conn, path)
      assert html_response(conn, 200) =~ "Success!"
    end

    test "GET /paper-details", %{conn: conn, pub: pub} do
      assigns = [publication_id: pub.id, pico_search_id: 1]
      path = bear_path(conn, :paper_details, assigns)
      conn = get(conn, path)
      assert html_response(conn, 200) =~ "Paper details"
    end

    test "GET /check-validity", %{conn: conn, pub: pub, pico_search: ps} do
      insert_pico_outcomes(ps)

      questions =
        BearQuestion.check_validity_questions().questions
        |> insert_bear_questions("check_validity")

      in_light_question = Enum.find(questions, &(&1.question =~ "In light"))
      insert_bear_answer(in_light_question, pub, ps, %{index: 1, answer: "blah"})

      assigns = [publication_id: pub.id, pico_search_id: ps.id]
      path = bear_path(conn, :check_validity, assigns)
      conn = get(conn, path)
      assert html_response(conn, 200) =~ "Check validity"
    end

    test "GET /calculate-results - has not been filled in previously", %{conn: conn, pub: pub, pico_search: ps} do
      insert_pico_outcomes(ps)

      BearQuestion.calculate_results_questions().questions
      |> insert_bear_questions("calculate_results")

      assigns = [publication_id: pub.id, pico_search_id: ps.id]

      path = bear_path(conn, :calculate_results)
      conn = get(conn, path, assigns)
      assert html_response(conn, 200) =~ "Calculate results"
    end

    test "GET /calculate-results - all fields filled in previously", %{conn: conn, pub: pub, pico_search: ps} do
      insert_pico_outcomes(ps)

      questions =
        BearQuestion.calculate_results_questions().questions
        |> insert_bear_questions("calculate_results")

      yes_no_questions = Enum.take(questions, 4)

      Enum.map(yes_no_questions, &Repo.insert!(%BearAnswers{
        bear_question_id: &1.id,
        publication_id: pub.id,
        pico_search_id: ps.id,
        index: 1,
        answer: "10"
      }))

      assigns = [publication_id: pub.id, pico_search_id: ps.id]

      path = bear_path(conn, :calculate_results)
      conn = get(conn, path, assigns)
      assert html_response(conn, 200) =~ "Calculate results"
    end

    test "GET /calculate-results - some fields filled in previously", %{conn: conn, pub: pub, pico_search: ps} do
      insert_pico_outcomes(ps)

      questions =
        BearQuestion.calculate_results_questions().questions
        |> insert_bear_questions("calculate_results")

      yes_no_questions = Enum.take(questions, 2)

      Enum.map(yes_no_questions, &Repo.insert!(%BearAnswers{
        bear_question_id: &1.id,
        publication_id: pub.id,
        pico_search_id: ps.id,
        index: 1,
        answer: "10"
      }))

      assigns = [publication_id: pub.id, pico_search_id: ps.id]

      path = bear_path(conn, :calculate_results)
      conn = get(conn, path, assigns)
      assert html_response(conn, 200) =~ "Calculate results"
    end

    test "GET /relevance", %{conn: conn, pub: pub} do
      assigns = [publication_id: pub.id, pico_search_id: 1]
      q_list = BearQuestion.relevance_questions().questions
      insert_bear_questions(q_list, "relevance")
      path = bear_path(conn, :relevance, assigns)
      conn = get(conn, path)
      assert html_response(conn, 200) =~ "Relevance"
    end

    test "GET /relevance with expiry date filled in previously", %{conn: conn, pub: pub, pico_search: ps} do
      assigns = [publication_id: pub.id, pico_search_id: 1]

      expiry_date_question =
        BearQuestion.relevance_questions().questions
        |> insert_bear_questions("relevance")
        |> Enum.at(-1)

      Repo.insert!(%BearAnswers{
        bear_question_id: expiry_date_question.id,
        publication_id: pub.id,
        pico_search_id: ps.id,
        index: 1,
        answer: "5/9/2021"
      })

      path = bear_path(conn, :relevance, assigns)
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
      date = %{day: "1", month: "1", year: "2000"}
      date_answer = Map.put(params.bear_answers, :q_1, date)
      updated_params = Map.put(params, :bear_answers, date_answer)

      conn = post(conn, path, updated_params)
      assert html_response(conn, 302)
    end

    test "POST /bear-form save and continue later", %{conn: conn, pub: pub, pico_search: ps} do
      path = bear_path(conn, :create)
      conn = post(conn, path, %{pub_id: pub.id, pico_search_id: ps.id})
      assert html_response(conn, 302)
    end
  end

  describe "testing index of bear controller" do
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
    test "GET /bears", %{conn: conn} do
      conn = get conn, "/bears"
      assert html_response(conn, 200) =~ "BEARs"
    end

    test "GET /bears redirect to / when not logged in", %{conn: conn} do
      conn = get conn, "/bears"
      assert html_response(conn, 302)
    end

    @tag login_as: %{email: "email@example.com"}
    test "GET /bears when user has started a BEAR", %{conn: conn, user: user} do
      search = insert_search(user, true)
      note_search = insert_note(search)
      insert_pico_search(note_search)
      insert_publication(search)
      conn = get conn, "/bears"

      assert html_response(conn, 200) =~ "BEARs"
    end
  end
end
