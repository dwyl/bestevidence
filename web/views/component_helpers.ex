defmodule Bep.ComponentHelpers do
  @moduledoc """
  Renders all of the component files
  """
  use Phoenix.HTML
  alias Bep.ComponentView

  def component(template, assigns) do
    ComponentView.render "#{template}.html", assigns
  end

  def slug_link_helper(conn, str, f1, f2, route, classes, colour) do
    if conn.assigns.client.slug == "default" do
      link(str, [
        to: f2.(conn, route),
        class: classes,
        style: "background-color:#{colour}"
      ])
    else
      link(str, [
        to: f1.(conn, route, conn.assigns.client.slug),
        class: classes,
        style: "background-color:#{colour}"
      ])
    end
  end

  def be_for(name) do
    case name do
      "default" ->
        "BestEvidence"
      _ ->
        "BestEvidence for #{name}"
    end
  end
end
