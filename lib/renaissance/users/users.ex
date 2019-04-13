defmodule Renaissance.Users do
  alias Renaissance.{User, Repo}

  def register_user(params) do
    changeset = User.changeset(%User{}, params)

    Repo.insert(changeset)
  end

  def get_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def verify_login(email, password) do
    get_by_email(email)
    |> Bcrypt.check_pass(password)
  end
end
