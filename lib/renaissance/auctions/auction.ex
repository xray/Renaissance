defmodule Renaissance.Auction do
  use Ecto.Schema
  import Ecto.Changeset
  alias Renaissance.User

  @required_fields ~w(title description user_id price end_auction_at)a
  @optional_fields ~w()a

  schema "auctions" do
    field :title, :string
    field :description, :string
    field :price, Money.Ecto.Amount.Type
    field :end_auction_at, :utc_datetime
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(auction, attrs \\ %{}) do
    auction
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_price()
    |> validate_date()
  end

  defp validate_price(changeset) do
    {_, amount} = Money.Ecto.Amount.Type.dump(get_change(changeset, :price, 0))

    if 0 < amount do
      changeset
    else
      add_error(changeset, :price, "must be greater than 0")
    end
  end

  defp validate_date(changeset) do
    auction_complete = get_change(changeset, :end_auction_at)

    if DateTime.compare(DateTime.utc_now(), auction_complete || DateTime.utc_now()) == :lt do
      changeset
    else
      add_error(changeset, :end_auction_at, "should be in the future")
    end
  end
end
