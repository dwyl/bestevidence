alias Bep.{Repo, Type, User}
alias Ecto.Changeset

changes = %{
  email: System.get_env("SUPER_ADMIN_EMAIL"),
  password: System.get_env("SUPER_ADMIN_PASS")
}

super_type = Repo.insert!(%Type{type: "super-admin"})

%User{}
|> User.registration_changeset(changes)
|> Changeset.put_assoc(:types, [super_type])
|> Repo.insert!()
