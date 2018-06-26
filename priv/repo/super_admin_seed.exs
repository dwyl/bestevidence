alias Bep.{Repo, Type, User}
alias Ecto.Changeset

changes = %{
  email: System.get_env("SUPER_ADMIN_EMAIL"),
  password: System.get_env("SUPER_ADMIN_PASS")
}

super_admin_type = Repo.get_by(Type, type: "super-admin")

super_type =
  case super_admin_type do
    nil ->
      Repo.insert!(%Type{type: "super-admin"})
    type ->
      type
  end

%User{}
|> User.registration_changeset(changes)
|> Changeset.put_assoc(:types, [super_type])
|> Repo.insert!()
