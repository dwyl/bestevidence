defmodule Bep.SessionController do
  use Bep.Web, :controller
  alias Bep.Auth

  def new(conn, _) do
    if conn.assigns.current_user do
      redirect(conn, to: search_path(conn, :index))
    else
      bg_colour = get_client_colour(conn, :login_page_bg_colour)
      btn_colour = get_client_colour(conn, :btn_colour)
      render(
        conn,
        "new.html",
        bg_colour: bg_colour,
        btn_colour: btn_colour
      )
    end
  end

  def create(conn, %{"session" => %{"email" => email, "password" => pass}}) do
    case Auth.login_by_email_and_pass(conn, email, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: search_path(conn, :index))
      {:error, _reason, conn} ->
        bg_colour = get_client_colour(conn, :login_page_bg_colour)
        btn_colour = get_client_colour(conn, :btn_colour)

        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> render(
          "new.html",
          bg_colour: bg_colour,
          btn_colour: btn_colour
        )
    end
  end
end
