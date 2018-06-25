defmodule Bep.MessagesController do
  use Bep.Web, :controller

  def view_messages(conn, _params) do
    assigns = [messages: ["1", "2"]]
    render(conn, :view, assigns)
  end
end
