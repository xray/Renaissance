defmodule Renaissance.Bid do
  use Ecto.Schema
  import Ecto.Changeset
  alias Renaissance.{Auction, User}

  @required_fields ~w(auction_id bidder_id amount)a
  @optional_fields ~w()a

  schema "bids" do
    belongs_to :auction, Auction
    belongs_to :bidder, User
    field :amount, Money.Ecto.Amount.Type

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bid, attrs \\ %{}) do
    bid
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
