defmodule Bep.MessagesController do
  use Bep.Web, :controller
  alias Bep.{Messages, Repo}

  def view_messages(conn, _params) do
    query = create_query(conn)
    messages = Repo.all(query)
    assigns = [messages: messages]
    render(conn, :view, assigns)
  end

  def create_query(conn) do
    client_id = conn.assigns.client.id
    current_user_id = conn.assigns.current_user.id

    from m in Messages,
    where: m.to_all == true
    or m.to_client == ^client_id
    or m.to_user == ^current_user_id
  end
end
