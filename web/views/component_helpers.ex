defmodule Bep.ComponentHelpers do
  @moduledoc """
  Renders all of the component files
  """
  use Phoenix.HTML
  alias Bep.ComponentView
  alias Bep.Router.Helpers
  alias Bep.Type

  @nav_classes "pv3 link center pointer w-50 bep-gray "

  def component(template, assigns) do
    ComponentView.render "#{template}.html", assigns
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
        "BestEvidence for #{String.capitalize(name)}"
    end
  end

  def to_all_classes(conn) do
    bool =
      if Map.has_key?(conn.assigns, :to_all) do
        conn.assigns
        |> Map.get(:to_all)
        |> String.to_existing_atom()
      end

    case bool do
      true ->
        @nav_classes <> "bb bep-b--red"
      _ ->
        @nav_classes
    end
  end

  def to_user_classes(conn) do
    user_bool = Map.has_key?(conn.assigns, :to_user)
    all_bool =
      if Map.has_key?(conn.assigns, :to_all) do
        conn.assigns
        |> Map.get(:to_all)
        |> String.to_existing_atom()
      end

    cond do
      user_bool && !all_bool ->
        @nav_classes <> "bb bep-b--red"
      conn.request_path =~ "/super-admin/list-users" ->
        @nav_classes <> "bb bep-b--red"
      true ->
        @nav_classes
    end
  end

  def to_client_or_all(conn) do
    user_type = Type.get_user_type(conn.assigns.current_user)
    case user_type == "super-admin" do
      true -> [to_all: true]
      _ -> [to_client: conn.assigns.current_user.client_id]
    end
  end
end
