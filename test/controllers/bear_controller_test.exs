defmodule Bep.BearControllerTest do
  use Bep.ConnCase

  describe "Testing pico search controller" do
    setup %{conn: conn} do
      user = insert_user()
      inserted_search = insert_search(user)
      pub = insert_publication(inserted_search)

      conn =
        conn
        |> assign(:current_user, user)
        |> assign_message()

      {:ok, conn: conn, pub: pub}
    end

    test "GET /paper-details", %{conn: conn, pub: pub} do
      path = bear_path(conn, :paper_details, publication_id: pub.id)
      conn = get(conn, path)
      assert html_response(conn, 200) =~ "Paper details"
    end

    test "POST /paper-details save and continue later", %{conn: conn, pub: pub} do
      path = bear_path(conn, :create)
      conn = post(conn, path, %{pub_id: pub.id})
      assert html_response(conn, 302)
    end

    test "POST /paper-details go to check_validity", %{conn: conn, pub: pub} do
      path = bear_path(conn, :create)
      conn = post(conn, path, %{pub_id: pub.id, check_validity: "true"})
      assert html_response(conn, 302)
    end
  end
end
