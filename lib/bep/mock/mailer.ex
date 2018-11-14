defmodule Bep.Mailer.Mock do
  @moduledoc false

  def deliver_now(_) do
    IO.inspect("Email sent")
  end
end
