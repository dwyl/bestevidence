defmodule Bep.MessagesController do
  use Bep.Web, :controller
  alias Bep.Messages

  def view_messages(conn, _params) do
    messages = Messages.get_messages(conn)
    assigns = [messages: messages]
    render(conn, :view, assigns)
  end

  def list_users(conn, _params) do
    users = Messages.get_user_list()
    assigns = [hide_navbar: true, users: users]
    render(conn, :list_users, assigns)
  end
end
