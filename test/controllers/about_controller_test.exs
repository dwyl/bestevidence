defmodule Bep.AboutControllerTest do
  use Bep.ConnCase

  test "GET /about", %{conn: conn} do
    conn = get conn, "/about"
    assert html_response(conn, 200) =~ "About Best Evidence"
  end

end
