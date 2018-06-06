defmodule Bep.AboutControllerTest do
  use Bep.ConnCase

  test "GET /about", %{conn: conn} do
    conn = get conn, "/about"
    assert html_response(conn, 200) =~ "BestEvidence"
  end

  test "GET /about with client", %{conn: conn} do
    client = insert_client()
    path = client_slug_about_path(conn, :index, client.slug)
    conn = get(conn, path)
    assert html_response(conn, 200) =~ "BestEvidence for Testclient"
  end
end
