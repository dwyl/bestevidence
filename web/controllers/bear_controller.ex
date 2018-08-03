defmodule Bep.BearController do
  use Bep.Web, :controller
  alias Bep.{Publication}

  def paper_details(conn, %{"publication_id" => pub_id}) do
    publication = Repo.get!(Publication, pub_id)
    assigns = [publication: publication]
    render(conn, :paper_details, assigns)
  end

  def check_validity(conn, _params) do
    render(conn, :check_validity)
  end

  def calculate_results(conn, _params) do
    render(conn, :calculate_results)
  end

  def relevance(conn, _params) do
    render(conn, :relevance)
  end

  # create bear_form
  def create(conn, %{"next" => page}) do
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
