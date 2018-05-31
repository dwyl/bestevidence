defmodule Bep.Repo.Migrations.AddClientLogoStr do
  use Ecto.Migration
  import Ecto.Query

  def up do
    alter table(:clients) do
      add :logo_url, :string
    end

    flush()

    from(c in "clients",
      update: [set: [logo_url: "/images/city-logo.jpg"]],
      where: is_nil(c.logo_url)
    )
    |> Bep.Repo.update_all([])
  end

  def down do
    alter table(:clients) do
      remove :logo_url
    end
  end
end
