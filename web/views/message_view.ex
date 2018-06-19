defmodule Bep.MessageView do
  use Bep.Web, :view

  def render_chat_view(value) do
    if value do
      render("admin_chat.html")
    else
      render("user_chat.html")
    end
  end
end
