defmodule Bep.Email do
  @moduledoc false

  use Bamboo.Phoenix, view: Bep.EmailView

  def send_email(to_email_address, subject, message) do
    email = System.get_env("SES_EMAIL")

    new_email()
    |> to(to_email_address)
    |> from(email)
    |> subject(subject)
    |> text_body(message)
  end
end
