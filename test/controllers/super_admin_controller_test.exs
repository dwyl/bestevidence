defmodule Bep.SuperAdminControllerTest do
  use Bep.ConnCase
  alias Bep.Client

  @upload %Plug.Upload{path: "test/support/city-logo.jpg", filename: "city-logo.jpg"}
  @bad_upload %Plug.Upload{path: "test/support/bad-file.jpg", filename: "bad-file.jpg"}

  @valid_details %{
    name: "barts",
    login_page_bg_colour: "#4386f4",
    btn_colour: "#4386f4",
    search_bar_colour: "#4386f4",
    about_text: "about text",
    slug: "barts",
    client_logo: @upload
  }

  @no_logo %{
    name: "barts",
    login_page_bg_colour: "#4386f4",
    btn_colour: "#4386f4",
    search_bar_colour: "#4386f4",
    about_text: "about text",
    slug: "barts"
  }

  @invalid_details %{
    name: "barts",
    login_page_bg_colour: "#4386f4",
    btn_colour: "green",
    search_bar_colour: "#4386f4",
    about_text: "about text",
    client_logo: @upload
  }

  @bad_upload_details %{
    name: "barts",
    login_page_bg_colour: "#4386f4",
    btn_colour: "green",
    search_bar_colour: "#4386f4",
    about_text: "about text",
    client_logo: @bad_upload
  }

  describe "Testing super-admin with correct user" do
    setup %{conn: conn} do
      user = insert_user("super-admin")
      client = Repo.get_by(Client, name: "testClient")
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, client: client}
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

    test "POST /super-admin with bad s3 upload", %{conn: conn} do
      conn = post(
        conn, super_admin_path(conn, :create), client: @bad_upload_details
      )
      assert html_response(conn, 200) =~ "Background colour"
    end

    test "POST /super-admin with correct details", %{conn: conn} do
      conn = post(conn, super_admin_path(conn, :create), client: @valid_details)
      assert html_response(conn, 302)
    end

    test "POST /super-admin with form filled but no logo", %{conn: conn} do
      conn = post(conn, super_admin_path(conn, :create), client: @no_logo)
      assert html_response(conn, 200)
    end

    test "POST /super-admin with invalid details", %{conn: conn} do
      conn =
        post(conn, super_admin_path(conn, :create), client: @invalid_details)
      assert html_response(conn, 200) =~ "Background colour"
    end

    test "GET /super_admin/:id/edit", %{conn: conn, client: client} do
      conn = get(conn, "/super-admin/#{client.id}/edit")
      assert html_response(conn, 200) =~ "Background colour"
    end

    test "PUT /super_admin/:id with valid details", %{conn: conn, client: client} do
      conn = put(conn, "/super-admin/#{client.id}", client: @valid_details)
      assert html_response(conn, 302)
    end

    test "PUT /super_admin/:id with invalid details", %{conn: conn, client: client} do
      conn = put(conn, "/super-admin/#{client.id}", client: @invalid_details)
      assert html_response(conn, 200) =~ "Background colour"
    end
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
