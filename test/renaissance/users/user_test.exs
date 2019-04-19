defmodule Renaissance.Test.UserTest do
  use Renaissance.DataCase

  require Ecto.Query
  alias Renaissance.User
  alias Renaissance.Repo

  @user_one_params %{email: "mail@mail.com", password: "password"}
  @user_two_params %{email: "mail2@mail.com", password: "password123"}

  describe "user" do
    test "requires email" do
      changeset = User.changeset(%User{}, %{email: nil, password: @user_one_params.password})
      refute changeset.valid?
      assert %{email: ["can't be blank"]} = errors_on(changeset)
    end

    test "requires password" do
      changeset = User.changeset(%User{}, %{email: @user_one_params.email, password: nil})
      refute changeset.valid?
      assert %{password: ["can't be blank"]} = errors_on(changeset)
    end

    test "require unique email" do
      changeset_one = User.changeset(%User{}, @user_one_params)
      Repo.insert!(changeset_one)

      changeset_two =
        User.changeset(%User{}, %{email: @user_one_params.email, password: "password2"})

      {:error, output} = Repo.insert(changeset_two)
      refute output.valid?
    end

    test "populates the password_hash field" do
      changeset = User.changeset(%User{}, @user_two_params)
      Repo.insert!(changeset)

      data = Repo.get_by(User, email: @user_two_params.email)
      assert data.password_hash != nil
    end

    test "does not store password as plain-text" do
      changeset = User.changeset(%User{}, @user_two_params)
      Repo.insert!(changeset)

      data = Repo.get_by(User, email: "mail2@mail.com")
      assert data.password_hash != @user_two_params.password
    end
  end
end
