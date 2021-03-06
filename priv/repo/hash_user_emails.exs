defmodule Bep.HashUserEmails do
  use Ecto.Migration
  import Ecto.Query
  alias Bep.{Repo, User}

  Bep.Repo.all(User)
  |> Enum.map(fn(user) ->
    hashed_email =
      case String.contains?(user.email, "@") do
        true -> Bep.User.hash_str(user.email)
        _ -> user.email
      end

    from(u in "users",
      update: [set: [email: ^hashed_email]],
      where: ^user.email == u.email
    )
  end)
  |> Enum.map(&Repo.update_all(&1, []))
end
