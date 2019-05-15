defmodule Renaissance.Auction do
  use Ecto.Schema
  import Ecto.Changeset
  alias Renaissance.{User, Bid}
  alias Renaissance.Helpers.Validators

  @required_fields ~w(title description seller_id starting_amount end_auction_at)a
  @optional_fields ~w()a

  schema "auctions" do
    field :title, :string
    field :description, :string
    field :starting_amount, Money.Ecto.Amount.Type
    field :end_auction_at, :utc_datetime
    belongs_to :seller, User
    has_many :bids, Bid
    has_one :highest_bid, Bid

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(auction, attrs \\ %{}) do
    auction
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:seller_id, name: :auctions_user_id_fkey)
    |> Validators.validate_starting_amount()
    |> validate_end_datetime()
  end

  defp validate_end_datetime(changeset) do
    end_at = get_change(changeset, :end_auction_at)

    if DateTime.compare(DateTime.utc_now(), end_at || DateTime.utc_now()) == :lt do
      changeset
    else
      add_error(changeset, :end_auction_at, "should be in the future")
    end
  end
end
