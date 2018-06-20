defmodule Bep.MessageView do
  use Bep.Web, :view

  def render_chat_view(value, user_list) do
    if value do
      render("admin_chat.html", user_list: user_list)
    else
      render("user_chat.html")
    end
  end
end
