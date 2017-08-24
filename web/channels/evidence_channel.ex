defmodule Bep.EvidenceChannel do
  use Bep.Web, :channel
  alias Bep.Publication

  def join("evidence:" <> search_id, _params, socket) do
    {:ok, socket}
  end

  def handle_in("evidence", params, socket) do
    save_publication(socket, params)
  end

  defp save_publication(socket, payload) do
    changeset = Publication.changeset(%Publication{}, payload)
    tripdatabase_id = changeset.changes.tripdatabase_id
    publication = Repo.insert(
      changeset,
      on_conflict: [set: [tripdatabase_id:	tripdatabase_id]],
      conflict_target:	:tripdatabase_id
    )

    case publication do
      {:ok, _publication} ->
        {:reply, :ok, socket}
      {:error, _changeset} ->
        {:reply, {:error, %{error: changeset}}, socket}
    end
  end

end
