defmodule Bep.SuperAdminControllerTest do
  use Bep.ConnCase

  @upload %Plug.Upload{path: "test/support/city-logo.jpg", filename: "city-logo.jpg"}
  @valid_details %{
    name: "barts",
    login_page_bg_colour: "#4386f4",
    btn_colour: "#4386f4",
    search_bar_colour: "#4386f4",
    about_text: "about text",
    slug: "barts",
    client_logo: @upload
  }

  @invalid_details %{
    name: "barts",
    login_page_bg_colour: "#4386f4",
    btn_colour: "green",
    search_bar_colour: "#4386f4",
    about_text: "about text",
    client_logo: %{
      content_type: "image/jpg",
      filename: "cute-kitty.jpg",
      path: "blah"
    }
  }

  describe "Testing super-admin with correct user" do
    setup %{conn: conn} do
      user = insert_user("super-admin")
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn}
    end

    test "GET /", %{conn: conn} do
      conn = get(conn, "/search")
      assert html_response(conn, 302)
    end

    test "GET /super-admin", %{conn: conn} do
      conn = get(conn, "/super-admin")
      assert html_response(conn, 200) =~ "Super Admin"
    end

    test "GET /super-admin/new", %{conn: conn} do
      conn = get(conn, "/super-admin/new")
      assert html_response(conn, 200) =~ "Background colour"
    end

    # test "POST /super-admin/post with correct details", %{conn: conn} do
    #   conn = post(conn, super_admin_path(conn, :create, client: @valid_details))
    #   assert html_response(conn, 302)
    # end

    # test "POST /super-admin/post with invalid details", %{conn: conn} do
    #   conn =
    #     post(conn, super_admin_path(conn, :create, client: @invalid_details))
    #   assert html_response(conn, 200) =~ "Background colour"
    # end
  end

  describe "Testing super-admin route with incorrect users" do
    test "GET /super-admin with no user logged in", %{conn: conn} do
      conn = get(conn, "/super-admin")
      assert html_response(conn, 302)
    end

    test "GET /super-admin with incorrect user logged in", %{conn: conn} do
      user = insert_user()
      conn =
        conn
        |> assign(:current_user, user)
        |> get("/super-admin")

      assert html_response(conn, 302)
    end
  end
end
