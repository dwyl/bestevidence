defmodule MessagesControllerTest do
  use Bep.ConnCase
  alias Bep.{Client, MessagesController, Type, User}
  alias Ecto.Changeset

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
      conn =
        conn
        |> assign(:current_user, user)
        |> assign_message
      insert_user_msg_read(user)

      {:ok, conn: conn, user: user}
    end

    test "GET /messages?user=user_id", %{conn: conn, user: user} do
      path = messages_path(conn, :view_messages, user: user.id)
      conn = get(conn, path)
      assert html_response(conn, 200)
    end
  end

  describe "Testing Mesage controller as CA" do
    setup %{conn: conn} do
      user = insert_user("doctor", %{email: "test@user.com"})
      ca = insert_user("client-admin")
      conn = assign(conn, :current_user, ca)
      insert_user_msg_read(user)

      {:ok, conn: conn, user: user, ca: ca}
    end

    test "POST /super-admin/messages with valid details for to_user", %{conn: conn, user: user} do
      path = ca_messages_path(conn, :create)
      message = Map.update!(@message, :to_user, &(&1 = user.id))
      conn = post(conn, path, message: message)
      assert html_response(conn, 302)
    end

    test "POST /super-admin/messages with valid details for to_client", %{conn: conn} do
      path = ca_messages_path(conn, :create)
      current_user = conn.assigns.current_user
      message = Map.update!(@message, :to_client, &(&1 = current_user.id))
      conn = post(conn, path, message: message)
      assert html_response(conn, 200) =~ "Yes, I"
    end
  end

  describe "Testing Message controller as SA" do
    setup %{conn: conn} do
      user = insert_user("doctor", %{email: "test@user.com"})
      sa = insert_user("super-admin")
      conn = assign(conn, :current_user, sa)
      insert_user_msg_read(user)

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

    test "POST /super-admin/messages with invalid details", %{conn: conn} do
      path = sa_messages_path(conn, :create)
      message = Map.update!(@message, :body, &(&1 = ""))
      conn = post(conn, path, message: message)
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

  describe "testing get_user_id_to_msg helper function" do
    test "client-admin user looking at a message of a user in their client" do
      ca = insert_user("client-admin", %{email: "client@admin.com"})
      user = insert_user()
      MessagesController.get_user_id_to_msg(ca, user.id)
    end

    test "client-admin looking at a message of user not in their client" do
      ca = insert_user("client-admin", %{email: "client@admin.com"})
      client_params = %{
        name: "diffClient",
        login_page_bg_colour: "#4386f4",
        btn_colour: "#4386f4",
        search_bar_colour: "#4386f4",
        about_text: "about text",
        slug: "diffslug",
        logo_url: "/images/city-logo.jpg"
      }

      client =
        %Client{}
        |> Client.changeset(client_params)
        |> Repo.insert!()

      user_params = %{
        email: "diffclientuser@email.com",
        password: "supersecret",
      }

      type = Repo.insert!(%Type{type: "doctor"})

      user =
        %User{}
        |> User.registration_changeset(user_params)
        |> Changeset.put_assoc(:types, [type])
        |> Changeset.put_assoc(:client, client)
        |> Repo.insert!()

      MessagesController.get_user_id_to_msg(ca, user.id)
    end
  end
end
