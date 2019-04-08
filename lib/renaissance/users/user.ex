defmodule Renaissance.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string, unique: true
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
    |> hash_password()
  end

  defp hash_password(attrs) do
    password = get_change(attrs, :password)
    case password do
      nil ->
        attrs
      _ ->
        hash = Bcrypt.hash_pwd_salt(password)
        attrs |> put_change(:password_hash, hash)
      end
  end
end
