defmodule Renaissance.Test.UserTest do
    use Renaissance.DataCase

    require Ecto.Query
    alias Renaissance.{User, Repo}

    describe "user" do
        test "requires email" do
            changeset = User.changeset(%User{}, %{email: nil, password: "password"})
            refute changeset.valid?
            assert %{email: ["can't be blank"]} = errors_on(changeset)
        end

        test "requires password" do
            changeset = User.changeset(%User{}, %{email: "mail@mail.com", password: nil})
            refute changeset.valid?
            assert %{password: ["can't be blank"]} = errors_on(changeset)
        end

        test "require unique email" do
            changeset_one = User.changeset(%User{}, %{email: "mail@mail.com", password: "password"})
            Repo.insert!(changeset_one)

            changeset_two = User.changeset(%User{}, %{email: "mail@mail.com", password: "password2"})
            {:error, output} = Repo.insert(changeset_two)
            refute output.valid?
        end

        test "populates the password_hash field" do
            changeset = User.changeset(%User{}, %{email: "mail2@mail.com", password: "password"})
            Repo.insert!(changeset)

            data = Repo.get_by(User, email: "mail2@mail.com")
            assert data.password_hash != nil
        end

        test "does not store password as plain-text" do
            password = "password123"
            changeset = User.changeset(%User{}, %{email: "mail2@mail.com", password: password})
            Repo.insert!(changeset)

            data = Repo.get_by(User, email: "mail2@mail.com")
            assert data.password_hash != password
        end
    end
end
