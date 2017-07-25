defmodule Bep.ComponentHelpers do
  @moduledoc """
  Renders all of the component files
  """

  alias Bep.ComponentView

  def component(template, assigns) do
    ComponentView.render "#{template}.html", assigns
  end
end
