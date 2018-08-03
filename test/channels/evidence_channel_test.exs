defmodule Bep.EvidenceChannelTest do
  use Bep.ChannelCase
  alias Bep.EvidenceChannel

  test "send publication event on the channel - save publication in db" do
    user = insert_user()
    search = insert_search(user)
    socket = socket("", %{user_id: user.id})
    {:ok, _, socket} = subscribe_and_join(
      socket,
      EvidenceChannel,
      "evidence:#{search.id}"
    )
    data = %{
      search_id: "#{search.id}",
      url: "/publication_url",
      value: "Publication 1",
      tripdatabase_id: "01"
    }
    ref = push socket, "evidence", data
    assert_reply ref, :ok, %{}, 5000
  end

  test "scroll event" do
    user = insert_user()
    search = insert_search(user)
    socket = socket("user:id", %{user_id: user.id})
    {:ok, _, socket} = subscribe_and_join(
      socket,
      EvidenceChannel,
      "evidence:#{search.id}"
    )
    ref = push socket, "scroll", %{term: "search test"}
    # update the time out of assert_reply to 5s
    #  to let tripdatabase API the time to send back a response
    assert_reply ref, :ok, %{page: 2, content: _html}, 5000
  end
end
