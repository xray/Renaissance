defmodule Renaissance.Bid do
  use Ecto.Schema
  import Ecto.Changeset
  alias Renaissance.{Auction, User}
  alias Renaissance.Helpers.Constraint

  @required_fields ~w(auction_id bidder_id amount)a
  @optional_fields ~w()a
  @timestamps_opts [type: :utc_datetime]

  schema "bids" do
    belongs_to :auction, Auction
    belongs_to :bidder, User
    field :amount, Money.Ecto.Amount.Type

    timestamps(inserted_at: :created_at, updated_at: false)
  end

  @doc false
  def changeset(bid, attrs \\ %{}) do
    bid
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> Constraint.amount_constraint(:amount)
  end
end
