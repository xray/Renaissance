defmodule Renaissance.Test.UsersTest do
  use Renaissance.DataCase
  require Ecto.Query
  alias Renaissance.Users
  alias Renaissance.Repo

  @valid_attrs %{email: "mail@mail.com", password: "password"}

  describe "users" do
    test "stores valid" do
      Users.register_user(@valid_attrs)

      user = Users.get_by_email(@valid_attrs.email)
      assert user.email == @valid_attrs.email
      assert user.password_hash != @valid_attrs.password
    end

    test "does not store invalid" do
      Users.register_user(%{email: "mail@mail.com", password: nil})

      count = Repo.aggregate(Ecto.Query.from(p in "users"), :count, :id)
      assert 0 == count
    end

    test "verifies login when correct password for known user" do
      Users.register_user(@valid_attrs)
      assert Users.verify_login(@valid_attrs.email, @valid_attrs.password)
    end

    test "rejects login when invalid password for known user" do
      Users.register_user(@valid_attrs)

      assert {:error, "invalid password"} ==
               Users.verify_login(@valid_attrs.email, "wrong_password")
    end

    test "rejects login unknown user" do
      Users.register_user(@valid_attrs)

      assert {:error, "invalid user-identifier"} ==
               Users.verify_login("unknown@mail.com", "wrong_password")
    end
  end
end
