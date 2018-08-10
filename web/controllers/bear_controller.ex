defmodule Bep.BearController do
  use Bep.Web, :controller
  alias Bep.{BearAnswers, BearQuestion, PicoOutcome, PicoSearch, Publication}

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

  def check_validity(conn, %{"pico_search_id" => ps_id, "publication_id" => pub_id}) do
    all_questions = BearQuestion.all_questions_for_sec("check_validity", pub_id)
    in_light_question = Enum.find(all_questions, &(&1.question =~ @in_light))

    outcomes =
      1..9
      |> Enum.map(
      fn(index) ->
        from po in PicoOutcome,
        where: po.pico_search_id == ^ps_id and po.o_index == ^index,
        order_by: [desc: po.id],
        limit: 1
      end)
      |> Enum.map(&Repo.one/1)
      |> Enum.reject(&(&1 == nil))
      |> Enum.map(fn(po) ->
        query =
          from ba in BearAnswers,
          where: ba.bear_question_id == ^in_light_question.id
          and ba.publication_id == ^pub_id
          and ba.index == ^po.o_index,
          order_by: [desc: ba.id],
          limit: 1

        ba = Repo.one(query)
        case ba do
          nil ->
            Map.put(po, :answer, "")
          _ ->
            Map.put(po, :answer, ba.answer)
        end
      end)

    further_question = Enum.find(all_questions, &(&1.question =~ @further))
    questions =
      all_questions
      |> Enum.reject(&(&1.question =~ @in_light))
      |> Enum.reject(&(&1.question =~ @further))

    question_nums = 1..length(questions)

    assigns = [
      questions: Enum.zip(question_nums, questions),
      in_light: in_light_question,
      further: further_question,
      pub_id: pub_id,
      pico_search_id: ps_id,
      outcomes: outcomes
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

  # create bear_answers
  def create(conn, %{"next" => page, "pub_id" => pub_id, "pico_search_id" => ps_id} = params) do
    insert_bear_answers(params, pub_id, ps_id)
    redirect_path = get_path(conn, page, pub_id, ps_id)
    redirect(conn, to: redirect_path)
  end

  # save and continue later route for bear_form
  def create(conn, %{"pub_id" => pub_id, "pico_search_id" => ps_id} = params) do
    insert_bear_answers(params, pub_id, ps_id)
    redirect(conn, to: search_path(conn, :index))
  end

  # HELPERS
  def get_path(conn, page, pub_id, ps_id) do
    assigns = [publication_id: pub_id, pico_search_id: ps_id]
    case page do
      "check_validity" ->
        bear_path(conn, :check_validity, assigns)

      "calculate_results" ->
        bear_path(conn, :calculate_results, assigns)

      "relevance" ->
        bear_path(conn, :relevance, assigns)

      "complete_bear" ->
        search_path(conn, :index, assigns)
    end
  end

  def insert_bear_answers(params, pub_id, ps_id) do
    pub = Repo.get(Publication, pub_id)
    pico_search = Repo.get(PicoSearch, ps_id)

    params
    |> make_q_and_a_list()
    |> Enum.map(&BearAnswers.insert_ans(%BearAnswers{}, &1, pub, pico_search))
  end

  def make_q_and_a_list(params) do
    params
    |> Map.keys()
    |> Enum.filter(&(&1 =~ "q_"))
    |> Enum.map(fn(key) ->
      {bear_q_id, o_index} = get_bear_q_id_and_o_index(key)
      answer = Map.get(params, key)
      if answer != "" do
        {answer, bear_q_id, o_index}
      end
    end)
  end

  def get_bear_q_id_and_o_index(key) do
    str = key |> String.trim_leading("q_")

    case String.contains?(str, "o_index") do
      true ->
        [bear_q_id, _, _, o_index] = String.split(str, "_")
        {bear_q_id, o_index}
      false ->
        {str, nil}
    end
  end
end
