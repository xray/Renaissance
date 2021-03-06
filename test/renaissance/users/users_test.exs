defmodule Renaissance.Test.UsersTest do
  use Renaissance.DataCase
  alias Renaissance.{Repo, User, Users}

  @attrs %{email: "mail@mail.com", password: "password"}

  describe "insert/2" do
    test "stores valid" do
      {:ok, user} = Users.insert(@attrs)

      assert Repo.exists?(User)
      assert user.email == @attrs.email
      assert user.password_hash != @attrs.password
    end

    test "does not store invalid" do
      Users.insert(%{email: "mail@mail.com", password: nil})
      refute Repo.exists?(User)
    end
  end

  describe "exists?/1" do
    test "true when user with given id" do
      {:ok, user} = Users.insert(@attrs)
      assert Users.exists?(user.id)
    end

    test "false when no user with given id" do
      refute Users.exists?(0)
    end
  end

  describe "verify_login/2" do
    test "verifies login when correct password for known user" do
      Users.insert(@attrs)
      assert Users.verify_login(@attrs.email, @attrs.password)
    end

    test "rejects login when invalid password for known user" do
      Users.insert(@attrs)

      assert {:error, "invalid password"} == Users.verify_login(@attrs.email, "wrong_password")
    end

    test "rejects login unknown user" do
      Users.insert(@attrs)

      assert {:error, "invalid user-identifier"} ==
               Users.verify_login("unknown@mail.com", "wrong_password")
    end
  end
end
