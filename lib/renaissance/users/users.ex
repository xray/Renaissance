defmodule Renaissance.Users do
    alias Renaissance.{User, Repo}

    def register_user(params) do
        changeset = User.changeset(%User{}, params)

        Repo.insert(changeset)
    end
end
