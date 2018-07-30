defmodule Bep.BearController do
  use Bep.Web, :controller
  alias Bep.{Publication}

  def paper_details(conn, %{"publication_id" => pub_id}) do
    publication = Repo.get!(Publication, pub_id)
    assigns = [publication: publication]

    render(conn, :paper_details, assigns)
  end

  def create(conn, %{"pub_id" => pub_id, "check_validity" => "true"} = _params) do
    publication = Repo.get!(Publication, pub_id)
    assigns = [publication: publication]
    render(conn, :paper_details, assigns)
  end

  def create(conn, %{"pub_id" => _pub_id}) do
    redirect(conn, to: "/search")
  end
end
