defmodule Bep.PublicationController do
  use Bep.Web, :controller
  alias Bep.{Publication}

  def create(conn, payload) do
    changeset = Publication.changeset(%Publication{}, payload)
    tripdatabase_id = changeset.changes.tripdatabase_id
    publication = Repo.insert(
      changeset,
      on_conflict: [set: [tripdatabase_id:	tripdatabase_id]],
      conflict_target:	:tripdatabase_id
    )

    case publication do
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
