defmodule Bep.UserTest do
  use Bep.ModelCase
  alias Bep.User

  @valid_attrs %{email: "email@example.com", password: "supersecret"}
  @invalid_attrs_email %{email: "email@example.com    ", password: "supersecret"}

  test "user changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "user changeset invalid email" do
    changeset = User.changeset(%User{}, @invalid_attrs_email)
    refute changeset.valid?
  end
end
