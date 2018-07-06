alias Bep.{Client, OtherType, Repo, Type, User}
alias Ecto.Changeset

changes = %{
  email: "ca@email.com",
  password: "password",
}

ca_type = Repo.get_by(Type, type: "client-admin")
client = Repo.get_by(Client, name: "test")

user =
  %User{}
  |> User.registration_changeset(changes)
  |> Changeset.put_assoc(:types, [ca_type])
  |> Changeset.put_assoc(:client, client)
  |> Repo.insert!()

Repo.insert!(%OtherType{user_id: user.id, type: ""})
