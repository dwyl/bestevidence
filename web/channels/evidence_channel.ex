defmodule Bep.EvidenceChannel do
  use Bep.Web, :channel

  def join("evidence:" <> search_id, _params, socket) do
    {:ok, socket}
  end

  def handle_in("evidence", params, socket) do
    # count = socket.assigns[:count] || 1
    # push socket, "ping", %{count: count}
    IO.inspect "AAAAAAAAAAAAAA"
    IO.inspect params
    # broadcast!(socket, "evidence", %{ok: "okkkkk"})
    {:noreply, socket}
  end

end
