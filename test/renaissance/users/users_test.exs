defmodule Renaissance.Test.UsersTest do
  use Renaissance.DataCase
  alias Renaissance.{Users, User, Repo}

  describe "users" do

    test "stores a valid user record in db" do
      email = "mail@mail.com"
      password = "password"

      Users.register_user(%{email: email, password: password})

      data = Repo.get_by(User, email: "mail@mail.com")
      assert data.email == email
      assert data.password_hash != password
    end

    test "does not store an invalid changeset" do
      email = "mail@mail.com"
      password = nil

      Users.register_user(%{email: email, password: password})

      count = Repo.aggregate(Ecto.Query.from(p in "users"), :count, :id)
      assert 0 == count
    end

  end
end
