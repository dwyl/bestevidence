defmodule Bep.UserController do
  use Bep.Web, :controller
  alias Bep.{User, Auth}

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Auth.login(user)
        |> put_flash(:info, "Welcome to BestEvidence!")
        |> redirect(to: page_path(conn, :index))
      {:error, %{errors: [email: {"has already been taken", []}]}} ->
        conn
        |> redirect(to: session_path(conn, :new))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, _) do
   conn
   |> Auth.logout()
   |> redirect(to: page_path(conn, :index))
 end

end
