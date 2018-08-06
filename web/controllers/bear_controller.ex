defmodule Bep.BearController do
  use Bep.Web, :controller
  alias Bep.{BearQuestions, Publication}

  @in_light "In light of the above assessment,"
  @further "Any further comments?"

  def paper_details(conn, %{"publication_id" => pub_id}) do
    questions = BearQuestions.all_questions_for_sec("paper_details")
    publication = Repo.get!(Publication, pub_id)
    assigns = [publication: publication, questions: questions]
    render(conn, :paper_details, assigns)
  end

  def check_validity(conn, _params) do
    all_questions = BearQuestions.all_questions_for_sec("check_validity")
    in_light_question = Enum.find(all_questions, &(&1.question =~ @in_light))
    further_question = Enum.find(all_questions, &(&1.question =~ @further))
    questions =
      all_questions
      |> Enum.reject(&(&1.question =~ @in_light))
      |> Enum.reject(&(&1.question =~ @further))

    question_nums = 1..length(questions)

    assigns = [
      questions: Enum.zip(question_nums, questions),
      in_light: in_light_question,
      further: further_question
    ]

    render(conn, :check_validity, assigns)
  end

  def calculate_results(conn, _params) do
    all_questions = BearQuestions.all_questions_for_sec("calculate_results")

    assigns = [
      all_questions: all_questions
    ]

    render(conn, :calculate_results, assigns)
  end

  def relevance(conn, _params) do
    render(conn, :relevance)
  end

  # create bear_form
  def create(conn, %{"next" => page} = _params) do
    case page do
      "check_validity" ->
        path = bear_path(conn, :check_validity)
        redirect(conn, to: path)
      "calculate_results" ->
        path = bear_path(conn, :calculate_results)
        redirect(conn, to: path)
      "relevance" ->
        path = bear_path(conn, :relevance)
        redirect(conn, to: path)
      "complete_bear" ->
        path = search_path(conn, :index)
        redirect(conn, to: path)
    end
  end

  # save and continue later route for bear_form
  def create(conn, _params) do
    path = search_path(conn, :index)
    redirect(conn, to: path)
  end
end
