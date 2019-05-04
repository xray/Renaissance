defmodule Renaissance.Test.UsersTest do
  use Renaissance.DataCase
  alias Renaissance.{Repo, User, Users}

  @attrs %{email: "mail@mail.com", password: "password"}

  describe "register_user/2" do
    test "stores valid" do
      {:ok, user} = Users.register_user(@attrs)

      assert Repo.exists?(User) == true
      assert user.email == @attrs.email
      assert user.password_hash != @attrs.password
    end

    test "does not store invalid" do
      Users.register_user(%{email: "mail@mail.com", password: nil})
      assert Repo.exists?(User) == false
    end
  end

  describe "exists?/1" do
    test "true when user with given id" do
      {:ok, user} = Users.register_user(@attrs)
      assert Users.exists?(user.id) == true
    end

    test "false when no user with given id" do
      assert Users.exists?(0) == false
    end
  end

  describe "verify_login/2" do
    test "verifies login when correct password for known user" do
      Users.register_user(@attrs)
      assert Users.verify_login(@attrs.email, @attrs.password)
    end

    test "rejects login when invalid password for known user" do
      Users.register_user(@attrs)

      assert {:error, "invalid password"} == Users.verify_login(@attrs.email, "wrong_password")
    end

    test "rejects login unknown user" do
      Users.register_user(@attrs)

      assert {:error, "invalid user-identifier"} ==
               Users.verify_login("unknown@mail.com", "wrong_password")
    end
  end
end
