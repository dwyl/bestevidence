defmodule Bep.Repo.Migrations.UpdateClientWithStyle do
  use Ecto.Migration

  def change do
    alter table(:clients) do
      add :login_page_bg_colour, :string, null: false, default: "test"
      add :btn_colour, :string, null: false, default: "test"
      add :search_bar_colour, :string, null: false, default: "test"
      add :about_text, :text, null: false, default: "test"
    end
  end
end
