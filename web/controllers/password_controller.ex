defmodule Bep.PasswordController do
  use Bep.Web, :controller

  @mailgun_api_key Application.get_env :bep, :mailgun_api_key
  @mailgun_domain Application.get_env :bep, :mailgun_domain
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
    40
    |> gen_rand_string
    |> send_email(email)
    |> case do
      {:ok, _} ->
        conn
        |> put_flash(:info, """
          We've sent a password reset link to the email you entered.
          If you don't receive an email, make sure you entered the address
          correctly and try again
        """)
      {:error, _} ->
        conn
        |> put_flash(:error, "Something went wrong. Please try again.")
    end
  end

  defp gen_rand_string(length) do
    length |> :crypto.strong_rand_bytes |> Base.url_encode64
  end

  defp send_email(token, email) do
    url = "https://api:key-#{@mailgun_api_key}@api.mailgun.net/v3/#{@mailgun_domain}/messages"

    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    body = {:form, [
      from: "Best Evidence <best.evidence.dev@gmail.com>",
      to: email,
      subject: "Password Reset",
      html: """
      <p>
        You recently requested a password reset for your Best Evidence account.
      </p>
      <p>
        To reset your password,
        <a href="#{@base_url}/password/reset/#{token}">
          click here
        </a>
        and follow the instructions.
      </p>
      <p>
        If you didn't request a password reset, you can ignore this email, or
        <a href="mailto:bestevidencefeedback@gmail.com">
          contact our support team
        </a>
        if you have any questions
      </p>
      """
    ]}

    HTTPoison.request("post", url, body, headers)
  end
end
