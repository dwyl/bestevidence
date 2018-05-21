defmodule Bep.SessionController do
  use Bep.Web, :controller
  alias Bep.Auth

  def new(conn, _) do
    if conn.assigns.current_user do
      redirect(conn, to: search_path(conn, :index))
    else
      header_colour = get_client_colour(conn, :search_bar_colour)
      btn_colour = get_client_colour(conn, :btn_colour)
      render(
        conn,
        "new.html",
        header_colour: header_colour,
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
        header_colour = get_client_colour(conn, :header_colour)
        btn_colour = get_client_colour(conn, :btn_colour)

        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> render(
          "new.html",
          header_colour: header_colour,
          btn_colour: btn_colour
        )
    end
  end
end
