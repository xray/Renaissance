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
    has_many :auctions, Auction, foreign_key: :seller_id

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
    password = get_change(attrs, :password)

    if !is_nil(password) do
      hash = Bcrypt.hash_pwd_salt(password)
      put_change(attrs, :password_hash, hash)
    else
      attrs
    end
  end
end
