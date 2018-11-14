defmodule Bep.PasswordController do
  use Bep.Web, :controller
  import Comeonin.Bcrypt, only: [checkpw: 2]
  alias Bep.{PasswordReset, User, Repo, Email}
  @base_url Application.get_env :bep, :base_url
  @mailer Application.get_env(:bep, :mailer)

  def index(conn, _params) do
    btn_colour = get_client_colour(conn, :btn_colour)
    bg_colour = get_client_colour(conn, :login_page_bg_colour)

    render(conn, "index.html", btn_colour: btn_colour, bg_colour: bg_colour)
  end

  def request(conn, %{"email" => %{"email" => email}}) do
    btn_colour = get_client_colour(conn, :btn_colour)
    bg_colour = get_client_colour(conn, :login_page_bg_colour)

    conn
    |> send_password_reset_email(email, hours: 2)
    |> render("index.html", btn_colour: btn_colour, bg_colour: bg_colour)
  end

  def send_password_reset_email(conn, email, time, client \\ nil) do
    email_message =
      """
        We've sent a password reset link to the email you entered.
        If you don't receive an email, make sure you entered the address
        correctly and try again
      """

    email
    |> gen_token(time)
    |> case do
      {:error, _token} -> put_flash(conn, :info, email_message)
      {:ok, token} ->
        token
        |> send_email(conn, email, client)
        |> (fn _ -> put_flash(conn, :info, email_message) end).()
    end
  end

  defp gen_rand_string(length) do
    length |> :crypto.strong_rand_bytes |> Base.url_encode64
  end

  def gen_token(email, time) do
    token = gen_rand_string(42)
    hashed_email =
      email
      |> String.downcase()
      |> User.hash_str()

    User
    |> Repo.get_by(email: hashed_email)
    |> case do
      nil -> {:error, token}
      user ->
        user
        |> Ecto.build_assoc(:password_resets)
        |> PasswordReset.changeset(%{token: token}, time)
        |> Repo.insert!

        {:ok, token}
    end
  end

  defp send_email(token, conn, email, client) do
    url = create_link_str(conn, "#{@base_url}", "/password/reset?token=#{token}")

    body =
      case client == nil do
        true -> reset_password_email_text(url)
        _ -> set_ca_password_email_text(url, client)
      end

    subject =
      case client == nil do
        true -> "Best Evidence Password Reset"
        _ -> "You have been invited to be a BestEvidence Administrator"
      end

    email
    |> Email.send_email(subject, body)
    |> @mailer.deliver_now()
  end

  def error_msg_maker(changeset) do
    for {key, {message, _}} <- changeset.errors do
      cond do
        String.contains?(message, "%{count}") ->
          "password should be at least 6 characters"
        key == :password_confirmation ->
          "passwords do not match"
        true -> "#{key} #{message}"
      end
    end
    |> Enum.join(" and ")
    |> String.capitalize
  end

  def change_password(conn, %{
      "change_password" => %{
        "current_password" => current_password,
        "new_password" => new_password,
        "new_password_confirmation" => new_password_conf
      }
    }) do

    btn_colour = get_client_colour(conn, :btn_colour)
    bg_colour = get_client_colour(conn, :login_page_bg_colour)

    user = conn.assigns.current_user
    case user && checkpw(current_password, user.password_hash) do
      true ->
        user
        |> User.change_password_changeset(%{
          password: new_password, password_confirmation: new_password_conf
          })
        |> Repo.update
        |> case do
          {:ok, _} ->
            put_flash(conn, :info, "Password updated")
          {:error, changeset} ->
            err_msg = error_msg_maker(changeset)
            put_flash(conn, :error, err_msg)
        end
        |> render("change.html", btn_colour: btn_colour, bg_colour: bg_colour)
      false ->
        conn
        |> put_flash(:error, "Incorrect password")
        |> render("change.html", btn_colour: btn_colour, bg_colour: bg_colour)
    end
  end

  def change_password(conn, _params) do
    btn_colour = get_client_colour(conn, :btn_colour)
    bg_colour = get_client_colour(conn, :login_page_bg_colour)

    render(conn, "change.html", btn_colour: btn_colour, bg_colour: bg_colour)
  end

  def reset(conn, %{"token" => token}) do
    btn_colour = get_client_colour(conn, :btn_colour)
    bg_colour = get_client_colour(conn, :login_page_bg_colour)

    render(
      conn,
      "reset.html",
      token: token,
      btn_colour: btn_colour,
      bg_colour: bg_colour
    )
  end

  def reset(conn, %{
    "reset" => %{"token" => token, "password" => password,
    "email" => email, "password_confirmation" => password_confirmation}
  }) do

    btn_colour = get_client_colour(conn, :btn_colour)
    bg_colour = get_client_colour(conn, :login_page_bg_colour)

    request_pass_link = create_link_str(conn, "<a href=", "/password>here</a>")
    session_link = create_link_str(conn, "<a href=", "/sessions/new>here</a>")

    expired_error = """
      This password reset link has expired.
      Please request a new one #{request_pass_link}
    """
    email_error = """
      This link is not valid for the given email address.
      Please make sure the email address is correct and try again.
    """
    success_message = """
      Your password has been updated. Please login #{session_link}
    """

    return_error = fn(error) ->
      conn
      |> put_flash(:error, error)
      |> render(
        "reset.html",
        token: token,
        btn_colour: btn_colour,
        bg_colour: bg_colour
      )
    end

    hashed_email =
      email
      |> String.downcase()
      |> User.hash_str()

    case Repo.get_by(User, email: hashed_email) do
      nil -> return_error.(email_error)
      user ->
        case Repo.get_by(PasswordReset, user_id: user.id, token: token) do
          nil -> return_error.(expired_error)
          reset ->
            if Timex.before?(Timex.now, reset.token_expires) do
              user
              |> User.change_password_changeset(%{
                password: password, password_confirmation: password_confirmation
                })
              |> Repo.update
              |> case do
                {:ok, _} ->
                  Repo.delete(reset)
                  put_flash(conn, :info, success_message)
                {:error, changeset} ->
                  err_msg = error_msg_maker(changeset)
                  put_flash(conn, :error, err_msg)
              end
              |> render(
                "reset.html",
                token: token,
                btn_colour: btn_colour,
                bg_colour: bg_colour
              )
            else
              Repo.delete(reset)
              return_error.(expired_error)
            end
        end
    end
  end

  def create_link_str(conn, str1, str2) do
    slug = conn.assigns.client.slug
      case slug do
        "default" ->
          str1 <> str2
        slug ->
          "#{str1}/#{slug}#{str2}"
      end
  end

  defp reset_password_email_text(url) do
    """
      You recently requested a password reset for your Best Evidence account.

      To reset your password, follow the link
      #{url}
      and follow the instructions.

      If the link above does not work please copy and paste it into your browser.

      If you didn't request a password reset, you can ignore this email, or
      contact our support team via email if you have any questions bestevidencefeedback@gmail.com
    """
  end

  defp set_ca_password_email_text(url, client) do
    """
      You have been made the client administrator for the #{client.name} version of the BestEvidence app.

      Please create a password at the following link:
      #{url}

      Please contact Dr Amanda Burls on 07788 124 764 or email me on BestEvidenceFeedback@gmail.com if you have any questions or problems.
    """
  end
end
