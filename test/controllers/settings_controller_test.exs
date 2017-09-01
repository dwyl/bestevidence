defmodule Bep.SettingsControllerTest do
  use Bep.ConnCase
  setup %{conn: conn} = config do
    if user = config[:login_as] do
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  @tag login_as: %{email: "email@example.com", id: 1}
  test "GET /settings", %{conn: conn} do
    conn = get conn, "/settings"
    assert html_response(conn, 200) =~ "Settings"
  end
end
