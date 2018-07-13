alias Bep.{Client, Repo, Type, User, UserType}
alias Ecto.Changeset
import Ecto.Query

sa_details = %{
  email: System.get_env("SUPER_ADMIN_EMAIL"),
  password: System.get_env("SUPER_ADMIN_PASS")
}

def_client = %{
  name: "testClient",
  login_page_bg_colour: "#4386f4",
  btn_colour: "#4386f4",
  search_bar_colour: "#4386f4",
  about_text: "about text",
  slug: "testSlug",
  logo_url: "/images/city-logo.jpg"
}

default_client =
  case Repo.get_by(Client, name: "default") do
    nil ->
      %Client{}
      |> Client.changeset(def_client)
      |> Repo.insert!()
    client ->
      client
  end

super_type =
  case Repo.get_by(Type, type: "super-admin") do
    nil ->
      Repo.insert!(%Type{type: "super-admin"})
    type ->
      type
  end

get_sa_query =
  from u in User,
  join: ut in UserType, on: u.id == ut.user_id,
  join: t in Type, on: t.id == ut.type_id,
  where: t.type == "super-admin"

case Repo.all(get_sa_query) do
  [] ->
    %User{}
    |> User.registration_changeset(sa_details)
    |> Changeset.put_assoc(:types, [super_type])
    |> Changeset.put_change(:client_id, default_client.id)
    |> Repo.insert!()
  [user | _] ->
    user
    |> Repo.preload(:types)
    |> Repo.preload(:client)
    |> User.registration_changeset(sa_details)
    |> Changeset.put_change(:client_id, default_client.id)
    |> Repo.update!()
end
