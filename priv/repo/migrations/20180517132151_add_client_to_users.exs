defmodule Bep.Repo.Migrations.AddClientToUsers do
  use Ecto.Migration
  import Ecto.Query
  alias Bep.{Client, Repo}

  def change do
    default_client =
      Repo.insert!(%Client{
        name: "default",
        slug: "default",
        login_page_bg_colour: "#8f182e",
        btn_colour: "#8f182e",
        search_bar_colour: "#8f182e",
        about_text: "about text"
      })

    alter table(:users) do
      add :client_id, references(:clients)
    end

    flush()

    from(u in "users",
      update: [set: [client_id: ^default_client.id]],
      where: is_nil(u.client_id)
    )
    |> Repo.update_all([])
  end

  def down do
    alter table(:users) do
      remove :client_id
    end

    flush()

    Client
    |> Repo.get_by!(name: "default")
    |> Repo.delete!()
  end
end
