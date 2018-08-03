defmodule Bep.BearQuestions do
  use Bep.Web, :model
  alias Bep.{BearQuestions, Repo}
  import Ecto.Query

  @moduledoc false

  schema "bear_questions" do
    field :section, :string
    field :question, :string
  end

  def all_questions_for_sec(section) do
    Repo.all(
      from bq in BearQuestions,
      where: bq.section == ^section
    )
  end
end
