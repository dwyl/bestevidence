defmodule Bep.ComponentHelpers do
  @moduledoc """
  Renders all of the component files
  """
  use Phoenix.HTML
  alias Bep.ComponentView

  def component(template, assigns) do
    ComponentView.render "#{template}.html", assigns
  end

  def slug_link_helper(conn, str, f1, f2, route, classes) do
    if Map.has_key?(conn.assigns, :client) do
      link(str, [
        to: f1.(conn, route, conn.assigns.client.slug),
        class: classes
      ])
    else
      link(str, [to: f2.(conn, route), class: classes])
    end
  end
end
