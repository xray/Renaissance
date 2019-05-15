defmodule Renaissance.Bid do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias Renaissance.{Auction, User}
  alias Renaissance.Helpers.Validators

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
    |> foreign_key_constraint(:bidder_id)
    |> foreign_key_constraint(:auction_id)
    |> unique_constraint(:amount, name: :bids_amount_auction_id_index)
    |> Validators.validate_bid_amount()
    |> Validators.validate_bidder(:bidder_id)
    |> Validators.validate_open(:amount)
  end

  def highest do
    highest_bids =
      from(b in __MODULE__,
        group_by: b.auction_id,
        select: %{auction_id: b.auction_id, amount: max(b.amount)}
      )

    from(b in __MODULE__,
      join: b2 in subquery(highest_bids),
      on: b.auction_id == b2.auction_id and b.amount == b2.amount
    )
  end
end
