defmodule Bep.Repo.Migrations.AddClientAdminToTypes do
  use Ecto.Migration
  alias Bep.{Repo, Type}

  def up do
    case Repo.get_by(Type, type: "client-admin") do
      nil -> 
        Repo.insert(%Type{type: "client-admin"})
      _ ->
        nil
    end
  end

  def down do
    client_admin = Repo.get_by(Type, type: "client-admin")
    Repo.delete!(client_admin)
  end
end
