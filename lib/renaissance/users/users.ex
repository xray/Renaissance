defmodule Renaissance.Users do
  alias Renaissance.{User, Repo}

  def register_user(params) do
    changeset = User.changeset(%User{}, params)
    Repo.insert(changeset)
  end

  def get(id) do
    Repo.get(User, id)
  end

  def verify_login(email, password) do
    Repo.get_by(User, email: email)
    |> Bcrypt.check_pass(password)
  end
end
