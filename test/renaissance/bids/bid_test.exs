defmodule Renaissance.Test.BidTest do
  use Renaissance.DataCase
  alias Renaissance.{Auctions, Users, Bid}

  @auction_params %{
    "title" => "Test Title",
    "description" => "Test description.",
    "end_auction_at" => %{
      "day" => 15,
      "hour" => 14,
      "minute" => 3,
      "month" => 4,
      "year" => 3019
    },
    "price" => "1.00"
  }

  setup _context do
    {:ok, seller} = Users.register_user(%{email: "seller@mail.com", password: "password"})
    {:ok, auction} = Auctions.create_auction(seller.id, @auction_params)
    {:ok, bidder} = Users.register_user(%{email: "bidder@mail.com", password: "password"})

    [
      valid_params: %{
        bidder_id: bidder.id,
        auction_id: auction.id,
        amount: 101
      }
    ]
  end

  test "accepts an initial valid auction bid", %{valid_params: valid_params} do
    changeset = Bid.changeset(%Bid{}, valid_params)
    assert changeset.valid?
  end

  test "rejects bid with non-positive amount", %{valid_params: valid_params} do
    invalid_params = %{valid_params | amount: -100}
    changeset = Bid.changeset(%Bid{}, invalid_params)

    refute changeset.valid?
    assert "must be greater than 0" in errors_on(changeset).amount
  end

  test "rejects bid with no bidder_id", %{valid_params: valid_params} do
    invalid_params = %{valid_params | bidder_id: nil}
    changeset = Bid.changeset(%Bid{}, invalid_params)

    refute changeset.valid?
    assert "can't be blank" in errors_on(changeset).bidder_id
  end

  test "rejects bid with no auction_id", %{valid_params: valid_params} do
    invalid_params = %{valid_params | auction_id: nil}
    changeset = Bid.changeset(%Bid{}, invalid_params)

    refute changeset.valid?
    assert "can't be blank" in errors_on(changeset).auction_id
  end
end
