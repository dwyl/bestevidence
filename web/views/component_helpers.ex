defmodule Bep.ComponentHelpers do
  @moduledoc """
  Renders all of the component files
  """
  use Phoenix.HTML
  alias Bep.ComponentView
  alias Bep.Router.Helpers
  alias Bep.Type

  def component(template, assigns) do
    ComponentView.render "#{template}.html", assigns
  end

  def about_path_for_reg_or_cli(conn) do
    client = conn.assigns.client
    case client.name do
      "default" ->
        Helpers.about_path(conn, :index)
      _ ->
        Helpers.client_slug_about_path(conn, :index, client.slug)
    end
  end

  def msg_link_path(conn) do
    user_type = Type.get_user_type(conn.assigns.current_user)

    case user_type do
      "client-admin" ->
        Helpers.ca_messages_path(conn, :list_users)
      "regular" ->
        user_id = conn.assigns.current_user.id
        Helpers.messages_path(conn, :view_messages, %{user: user_id})
    end
  end

  def send_to_client_or_all(conn) do
    user = conn.assigns.current_user
    user_type = Type.get_user_type(user)

    case user_type do
      "client-admin" ->
        [to_client: user.client_id]
      "super-admin" ->
        [to_all: true]
    end
  end

  def slug_link_helper(conn, str, f1, f2, route, classes, colour) do
    if conn.assigns.client.slug == "default" do
      link(str, [
        to: f2.(conn, route),
        class: classes,
        style: "background-color:#{colour}"
      ])
    else
      link(str, [
        to: f1.(conn, route, conn.assigns.client.slug),
        class: classes,
        style: "background-color:#{colour}"
      ])
    end
  end

  def be_for(name) do
    case name do
      "default" ->
        "BestEvidence"
      _ ->
        "BestEvidence for #{name}"
    end
  end

  def msg_all_class(conn) do
    cond do
      Map.has_key?(conn.params, "to_client") ->
        "bb bep-b--red"
      Map.has_key?(conn.params, "to_all") ->
        "bb bep-b--red"
      true ->
        ""
    end
  end

  def msg_individual_class(conn) do
    cond do
      conn.request_path =~ "list-users" ->
        "bb bep-b--red"
      conn.request_path =~ "/messages" && Map.has_key?(conn.params, "user") ->
        "bb bep-b--red"
      Map.has_key?(conn.params, "to_user") ->
        "bb bep-b--red"
      true ->
        ""
    end
  end
end
