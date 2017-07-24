defmodule Bep.PublicationController do
  use Bep.Web, :controller
  alias Bep.Publication

  def create(conn, payload) do
    changeset = Publication.changeset(%Publication{}, payload)
    case Repo.insert(changeset) do
      {:ok, _publication} ->
        conn
        |> put_status(200)
        |> json(%{ok: "publication saved"})
      {:error, _changeset} ->
        conn
        |> put_status(500)
        |> json(%{error: "publication not saved!"})
    end
  end
end
