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

  @valid_ca %{
    email: "ca@test.com"
  }

  @invalid_ca %{
    email: "ca"
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
        conn, sa_super_admin_path(conn, :create), client: @bad_upload_details
      )
      assert html_response(conn, 200) =~ "Background colour"
    end

    test "POST /super-admin with correct details", %{conn: conn} do
      path = sa_super_admin_path(conn, :create)
      conn = post(conn, path, client: @valid_details)
      assert html_response(conn, 200) =~ "Create client admin"
    end

    test "POST /super-admin with form filled but no logo", %{conn: conn} do
      conn = post(conn, sa_super_admin_path(conn, :create), client: @no_logo)
      assert html_response(conn, 200)
    end

    test "POST /super-admin with invalid details", %{conn: conn} do
      conn =
        post(conn, sa_super_admin_path(conn, :create), client: @invalid_details)
      assert html_response(conn, 200) =~ "Background colour"
    end

    test "GET /super-admin/new-client-admin?client_id=:id", %{conn: conn, client: client} do
      assigns = [client_id: client.id]
      path = sa_super_admin_path(conn, :new_client_admin, assigns)
      conn = get(conn, path)
      assert html_response(conn, 200) =~ "Create client admin"
    end

    test "POST /super-admin/create-client-admin with correct details", %{conn: conn, client: client} do
      path = sa_super_admin_path(conn, :create_client_admin)
      client_admin = Map.put(@valid_ca, :client_id, client.id)
      conn = post(conn, path, user: client_admin)
      assert html_response(conn, 302)
    end

    test "POST /super-admin/create-client-admin with incorrect details", %{conn: conn, client: client} do
      path = sa_super_admin_path(conn, :create_client_admin)
      client_admin = Map.put(@invalid_ca, :client_id, client.id)
      conn = post(conn, path, user: client_admin)
      assert html_response(conn, 200) =~ "Create client admin"
    end

    test "GET /super_admin/:id/edit", %{conn: conn, client: client} do
      insert_user("client-admin", %{email: "test@user.com"})
      conn = get(conn, "/super-admin/#{client.id}/edit")
      assert html_response(conn, 200) =~ "Background colour"
    end

    test "PUT /super_admin/:id with valid details", %{conn: conn, client: client} do
      conn = put(conn, "/super-admin/#{client.id}", client: @valid_details)
      assert html_response(conn, 302)
    end

    test "PUT /super_admin/:id with valid details but no logo", %{conn: conn, client: client} do
      valid_with_logo = Map.delete(@valid_details, :client_logo)
      conn = put(conn, "/super-admin/#{client.id}", client: valid_with_logo)
      assert html_response(conn, 302)
    end

    test "PUT /super_admin/:id with invalid details", %{conn: conn, client: client} do
      conn = put(conn, "/super-admin/#{client.id}", client: @invalid_details)
      assert html_response(conn, 200) =~ "Background colour"
    end

    test "GET /super_admin/edit-client-admin?client_admin_id=:id", %{conn: conn} do
      path = sa_super_admin_path(conn, :edit_client_admin, [client_admin_id: 4])
      conn = get(conn, path)
      assert html_response(conn, 200) =~ "Edit client admin"
    end

    test "PUT /super_admin/update-client-admin with invalid details", %{conn: conn} do
      user = insert_user("doctor", %{email: "test@user.com"})
      user_params = %{email: "ca"}
      path = sa_super_admin_path(conn, :update_client_admin, user.id)
      conn = put(conn, path, user: user_params, id: user.id)
      assert html_response(conn, 200) =~ "Edit client admin"
    end

    test "PUT /super_admin/update-client-admin with valid details", %{conn: conn} do
      user = insert_user("client-admin", %{email: "test@user.com"})
      user_params = %{email: "ca@email.com"}
      path = sa_super_admin_path(conn, :update_client_admin, user.id)
      conn = put(conn, path, user: user_params, id: user.id)
      assert html_response(conn, 302)
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
