alias Bep.{Repo, Type}

Type
|> Repo.get_by(type: "special")
|> Ecto.Changeset.change(type: "other")
|> Repo.update!
