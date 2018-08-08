defmodule Bep.BearController do
  use Bep.Web, :controller
  alias Bep.{BearAnswers, BearQuestion, PicoSearch, Publication}
  alias Ecto.Changeset

  @in_light "In light of the above assessment,"
  @further "Any further comments?"

  def paper_details(conn, %{"publication_id" => pub_id, "pico_search_id" => ps_id}) do
    questions = BearQuestion.all_questions_for_sec("paper_details", pub_id)
    publication = Repo.get!(Publication, pub_id)

    assigns = [
      publication: publication,
      questions: questions,
      pico_search_id: ps_id
    ]

    render(conn, :paper_details, assigns)
  end

  def check_validity(conn, _params) do
    all_questions = BearQuestion.all_questions_for_sec("check_validity", 1)
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
    all_questions = BearQuestion.all_questions_for_sec("calculate_results", 1)

    assigns = [
      all_questions: all_questions
    ]

    render(conn, :calculate_results, assigns)
  end

  def relevance(conn, _params) do
    question_nums = 1..3
    all_questions = BearQuestion.all_questions_for_sec("relevance", 1)

    {first_three, rest} = Enum.split(all_questions, 3)
    {[prob, comment], dates} = Enum.split(rest, 2)

    assigns = [
      first_three: Enum.zip(question_nums, first_three),
      prob: prob,
      comment: comment,
      dates: dates
    ]
    render(conn, :relevance, assigns)
  end

  # create bear_form
  def create(conn, %{"next" => page} = params) do
    case page do
      "check_validity" ->
        insert_paper_details(params)
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

  def insert_paper_details(params) do
    %{"pub_id" => pub_id, "pico_search_id" => pico_search_id} = params
    pub = Repo.get(Publication, pub_id)
    pico_search = Repo.get(PicoSearch, pico_search_id)

    params
    |> make_q_and_a_list()
    |> Enum.map(&insert_ans(&1, pub, pico_search))
  end

  def make_q_and_a_list(params) do
    params
    |> Map.keys()
    |> Enum.filter(&(&1 =~ "q_"))
    |> Enum.map(fn(key) ->
      bear_q_id = String.trim_leading(key, "q_")
      value = Map.get(params, key)
      if value != "" do
        %{answer: value, bear_q_id: bear_q_id}
      end
    end)
  end

  def insert_ans(q_and_a_map, pub, pico_search) do
    if q_and_a_map != nil do
      %{:answer => answer, :bear_q_id => q_id} = q_and_a_map
      bear_question = Repo.get(BearQuestion, q_id)

      %BearAnswers{}
      |> BearAnswers.paper_details_changeset(%{answer: answer})
      |> Changeset.put_assoc(:bear_question, bear_question)
      |> Changeset.put_assoc(:publication, pub)
      |> Changeset.put_assoc(:pico_search, pico_search)
      |> Repo.insert!()
    end
  end
end
