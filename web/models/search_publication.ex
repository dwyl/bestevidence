defmodule Bep.SearchPublication do
  @moduledoc """
  schema that represents the table searches_publications which do the link
  between searches of the users and the publications
  """
  use Bep.Web, :model
  alias Bep.{Search, Publication}
  @primary_key false
  schema "searches_publications" do
    belongs_to	:search,	Search
    belongs_to	:publication,	Publication
    timestamps()
  end
end
