defmodule Bep.Question do
  use Bep.Web, :model

  @moduledoc """
  Question model
  """

  schema "questions" do
    field	:section,	:string
    field	:question, :string
    timestamps()
  end
end
