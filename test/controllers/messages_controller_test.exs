defmodule MessagesControllerTest do
  use Bep.ConnCase

  @message %{
    subject: "subject",
    body: "body",
    to_all: "false",
    to_client: "",
    to_user: "",
    confirm: "false",
    return_to_message: "false"
  }

  describe "Testing Message controller as standard user" do
    setup %{conn: conn} do
      user = insert_user()
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    test "GET /messages?user=user_id", %{conn: conn, user: user} do
      path = messages_path(conn, :view_messages, user: user.id)
      conn = get(conn, path)
      assert html_response(conn, 200)
    end
  end

  describe "Testing Message controller as SA" do
    setup %{conn: conn} do
      user = insert_user("doctor", %{email: "test@user.com"})
      sa = insert_user("super-admin")
      conn = assign(conn, :current_user, sa)

      {:ok, conn: conn, user: user, sa: sa}
    end

    test "GET /super-admin/messages?user=user_id", %{conn: conn, user: user} do
      path = sa_messages_path(conn, :view_messages, user: user.id)
      conn = get(conn, path)
      assert html_response(conn, 200)
    end

    test "GET /super-admin/list-users", %{conn: conn} do
      path = sa_messages_path(conn, :list_users)
      conn = get(conn, path)
      assert html_response(conn, 200)
    end

    test "GET /super-admin/message_sent", %{conn: conn} do
      path = sa_messages_path(conn, :message_sent)
      conn = get(conn, path)
      assert html_response(conn, 200)
    end

    test "GET /super-admin/messages/new?to_all=true", %{conn: conn} do
      path = sa_messages_path(conn, :new, [to_all: "true"])
      conn = get(conn, path)
      assert html_response(conn, 200)
    end

    test "POST /super-admin/messages with invalid details", %{conn: conn, user: user} do
      path = sa_messages_path(conn, :create)
      conn = post(conn, path, message: %{to_user: user.id})
      assert html_response(conn, 200)
    end

    test "POST /super-admin/messages with valid details for to_user", %{conn: conn, user: user} do
      path = sa_messages_path(conn, :create)
      message = Map.update!(@message, :to_user, &(&1 = user.id))
      conn = post(conn, path, message: message)
      assert html_response(conn, 302)
    end

    test "POST /super-admin/messages with valid details for to_all renders confirm page", %{conn: conn} do
      path = sa_messages_path(conn, :create)
      message = Map.update!(@message, :to_all, &(&1 = "true"))
      conn = post(conn, path, message: message)
      assert html_response(conn, 200) =~ "Yes, I"
    end

    test "POST /super-admin/messages. SA confirms send redirects", %{conn: conn} do
      path = sa_messages_path(conn, :create)
      message =
        @message
        |> Map.update!(:to_all, &(&1 = "true"))
        |> Map.update!(:confirm, &(&1 = "true"))
      conn = post(conn, path, message: message)
      assert html_response(conn, 302)
    end

    test "POST /super-admin/messages. SA says return to message", %{conn: conn} do
      path = sa_messages_path(conn, :create)
      message =
        @message
        |> Map.update!(:to_all, &(&1 = "true"))
        |> Map.update!(:confirm, &(&1 = "false"))
        |> Map.update!(:return_to_message, &(&1 = "true"))
      conn = post(conn, path, message: message)
      assert html_response(conn, 200)
    end
  end
end
