defmodule Renaissance.User do
  use Ecto.Schema
  alias Renaissance.{Auction}
  import Ecto.Changeset

  @required_fields ~w(email password)a
  @optional_fields ~w()a

  schema "users" do
    field :email, :string, unique: true
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many :auctions, Auction

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:email)
    |> hash_password()
  end

  defp hash_password(attrs) do
    if is_nil(password = get_change(attrs, :password)) do
      attrs
    else
      hash = Bcrypt.hash_pwd_salt(password)
      attrs |> put_change(:password_hash, hash)
    end
  end
end
