defmodule Bep.SearchTest do
  use Bep.ModelCase

  alias Bep.Search

  @valid_attrs %{term: "some content"}
  @invalid_attrs %{}
  @search_history [%{updated_at: ~N[2017-08-09 12:46:46.086508]},
                   %{updated_at: ~N[2017-08-10 14:46:46.086508]},
                   %{updated_at: ~N[2017-08-03 11:45:46.086508]},
                   %{updated_at: ~N[2017-08-12 10:46:46.086508]},
                   %{updated_at: ~N[2017-08-01 15:46:46.086508]},
                  ]

  test "changeset with valid attributes" do
    changeset = Search.changeset(%Search{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Search.changeset(%Search{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "Searches are ordered by date" do
    ordered_search = Search.group_searches_by_day(@search_history)
    expected = [
                {"2017-08-12", [%{updated_at: ~N[2017-08-12 10:46:46.086508]}]},
                {"2017-08-10", [%{updated_at: ~N[2017-08-10 14:46:46.086508]}]},
                {"2017-08-09", [%{updated_at: ~N[2017-08-09 12:46:46.086508]}]},
                {"2017-08-03", [%{updated_at: ~N[2017-08-03 11:45:46.086508]}]},
                {"2017-08-01", [%{updated_at: ~N[2017-08-01 15:46:46.086508]}]}
               ]
    assert expected == ordered_search

  end

end
