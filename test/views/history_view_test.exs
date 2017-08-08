defmodule Bep.HistoryViewTest do
  use Bep.ConnCase, async: true
  import Bep.HistoryView

  test "format date publication - 2017-8-8" do
    assert format_date("2017-08-08") == "08-08-2017"
  end

end
