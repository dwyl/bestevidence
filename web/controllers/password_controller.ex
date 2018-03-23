defmodule Bep.PasswordController do
  use Bep.Web, :controller
  alias Bep.{PasswordReset, User, Repo}
  @base_url Application.get_env :bep, :base_url

  def index(conn, _params) do
    render conn, "index.html"
  end

  def request(conn, %{"email" => %{"email" => email}}) do
    conn
    |> send_password_reset_email(email)
    |> render("index.html")
  end

  defp send_password_reset_email(conn, email) do
    email_message = """
      We've sent a password reset link to the email you entered.
      If you don't receive an email, make sure you entered the address
      correctly and try again
    """

    email
    |> gen_token
    |> case do
      {:error, _token} -> put_flash(conn, :info, email_message)
      {:ok, token} ->
        token
        |> send_email(email)
        |> (fn _ -> put_flash(conn, :info, email_message) end).()
    end
  end

  defp gen_rand_string(length) do
    length |> :crypto.strong_rand_bytes |> Base.url_encode64
  end

  def gen_token(email) do
    token = gen_rand_string(40)

    Repo.get_by(User, email: email)
    |> case do
      nil -> {:error, token}
      user ->
        user
        |> Ecto.build_assoc(:password_resets)
        |> PasswordReset.changeset(%{token: token})
        |> Repo.insert!

        {:ok, token}
    end
  end

  defp send_email(token, email) do
    body = """
      You recently requested a password reset for your Best Evidence account.

      To reset your password, follow the link
      #{@base_url}/password/reset?token=#{token}
      and follow the instructions.

      If you didn't request a password reset, you can ignore this email, or
      contact our support team via email if you have any questions bestevidencefeedback@gmail.com
    """

    Bep.Email.send_email(email, "Best Evidence Password Reset", body)
    |> Bep.Mailer.deliver_now()
  end

  def reset(conn, %{"token" => token}) do
    render(conn, "reset.html", token: token)
  end

  def reset(conn, %{"reset" => %{"token" => token, "password" => password, "email" => email}}) do

    error_message = """
      This password reset link has expired.
      Please request a new one <a href=\"/password\">here</a>
    """
    success_message = """
      Your password has been updated. Please login <a href=\"/sessions/new\">here</a>
    """

    return_error = fn ->
      conn |> put_flash(:error, error_message) |> render("reset.html", token: token)
    end

    case Repo.get_by(User, email: email) do
      nil -> return_error.()
      user ->
        case Repo.get_by(PasswordReset, user_id: user.id, token: token) do
          nil -> return_error.()
          reset ->
            if Timex.before?(Timex.now, reset.token_expires) do
                User.registration_changeset(user, %{password: password})
                |> Repo.update
                |> case do
                  {:ok, _} ->
                    Repo.delete(reset)
                    put_flash(conn, :info, success_message)
                  {:error, _} ->
                    put_flash(conn, :error, error_message)
                end
                |> render("reset.html", token: token)
            else
              Repo.delete(reset)
              return_error.()
            end
        end
    end
  end
end
