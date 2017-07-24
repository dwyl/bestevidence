defmodule Bep.PublicationControllerTest do
  use Bep.ConnCase

  test "Attempt to save publication - Returns 500 if payload mal formed", %{conn: conn} do
    conn = post conn, publication_path(conn, :create, %{})
    assert json_response(conn, 500)
  end
end
