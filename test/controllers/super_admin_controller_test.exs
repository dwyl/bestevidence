defmodule Bep.SuperAdminControllerTest do
  use Bep.ConnCase

  @valid_details %{
    name: "barts",
    login_page_bg_colour: "#4386f4",
    btn_colour: "#4386f4",
    search_bar_colour: "#4386f4",
    about_text: "about text"
  }

  @invalid_details %{
    name: "barts",
    login_page_bg_colour: "#4386f4",
    btn_colour: "green",
    search_bar_colour: "#4386f4",
    about_text: "about text"
  }

  test "GET /super-admin", %{conn: conn} do
    conn = get conn, "/super-admin"
    assert html_response(conn, 200) =~ "Super Admin"
  end

  test "GET /super-admin/new", %{conn: conn} do
    conn = get conn, "/super-admin/new"
    assert html_response(conn, 200) =~ "Background colour"
  end

  test "POST /super-admin/post with correct details", %{conn: conn} do
    conn = post conn, super_admin_path(conn, :create, client: @valid_details)
    assert html_response(conn, 302)
  end

  test "POST /super-admin/post with invalid details", %{conn: conn} do
    conn = post conn, super_admin_path(conn, :create, client: @invalid_details)
    assert html_response(conn, 200) =~ "Background colour"
  end
end
