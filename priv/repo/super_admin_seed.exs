alias Bep.{Repo, Type, User}
alias Ecto.Changeset

changes = %{
  email: "super@admin.com",
  password: "password",
}

super_type = Repo.insert!(%Type{type: "super-admin"})

%User{}
|> User.registration_changeset(changes)
|> Changeset.put_assoc(:types, [super_type])
|> Repo.insert!()
