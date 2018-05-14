alias Bep.{Repo, User}

changes = %{
  email: "super@admin.com",
  password: "password",
}

%User{}
|> User.registration_changeset(changes)
|> Repo.insert!()
