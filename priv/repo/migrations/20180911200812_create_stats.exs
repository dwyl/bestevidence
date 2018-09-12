defmodule Bep.Repo.Migrations.CreateStats do
  use Ecto.Migration

  def change do
    create table(:bear_stats) do
      add :publication_id, references(:publications, on_delete: :delete_all)
      add :pico_search_id, references(:pico_searches, on_delete: :delete_all)
      add :index, :integer
      add :arr_mid, :string
      add :arr_low, :string
      add :arr_high, :string
      add :rr_mid, :string
      add :rr_low, :string
      add :rr_high, :string
      add :rrr_mid, :string
      add :rrr_low, :string
      add :rrr_high, :string
      add :or_mid, :string
      add :or_low, :string
      add :or_high, :string
      add :nnt_mid, :string
      add :nnt_low, :string
      add :nnt_high, :string
    end
  end
end
