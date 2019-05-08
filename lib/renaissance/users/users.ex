defmodule Renaissance.Users do
  import Ecto.Query
  alias Renaissance.{User, Repo}

  def insert(params) do
    User.changeset(%User{}, params)
    |> Repo.insert()
  end

  def exists?(id) do
    Repo.exists?(from u in User, where: u.id == ^id)
  end

  def get(id) do
    Repo.get(User, id)
  end

  def verify_login(email, password) do
    Repo.get_by(User, email: email)
    |> Bcrypt.check_pass(password)
  end
end
