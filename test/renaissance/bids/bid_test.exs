defmodule Renaissance.Test.BidTest do
  use Renaissance.DataCase
  alias Renaissance.{Auctions, Bid, Users}

  setup _context do
    {:ok, seller} = Users.insert(%{email: "seller@mail.com", password: "password"})
    {:ok, bidder} = Users.insert(%{email: "bidder@mail.com", password: "password"})

    end_time = %{"day" => 15, "hour" => 14, "minute" => 3, "month" => 4, "year" => 3019}

    auction_params = %{
      "title" => "Test Title",
      "description" => "Test description.",
      "end_auction_at" => end_time,
      "price" => "1.00",
      "seller_id" => seller.id
    }

    {:ok, auction} = Auctions.insert(auction_params)
    bid_params = %{bidder_id: bidder.id, auction_id: auction.id, amount: 101}

    [params: %{auction: auction_params, bid: bid_params}]
  end

  test "accepts an initial valid auction bid", %{params: params} do
    changeset = Bid.changeset(%Bid{}, params.bid)
    assert changeset.valid?
  end

  test "rejects bid with non-positive amount", %{params: params} do
    invalid_params = Map.put(params.bid, :amount, -100)
    changeset = Bid.changeset(%Bid{}, invalid_params)

    refute changeset.valid?

    message = ~s(must be greater than $#{params.auction["price"]})
    assert message in errors_on(changeset).amount
  end

  test "rejects bid unless amount exceeds current", %{params: params} do
    invalid_params = Map.put(params.bid, :amount, 1)
    changeset = Bid.changeset(%Bid{}, invalid_params)

    refute changeset.valid?

    message = ~s(must be greater than $#{params.auction["price"]})
    assert message in errors_on(changeset).amount
  end

  test "rejects bid with no bidder_id", %{params: params} do
    invalid_params = Map.put(params.bid, :bidder_id, nil)
    changeset = Bid.changeset(%Bid{}, invalid_params)

    refute changeset.valid?
    assert "can't be blank" in errors_on(changeset).bidder_id
  end

  test "rejects bid with no auction_id", %{params: params} do
    invalid_params = Map.put(params.bid, :auction_id, nil)
    changeset = Bid.changeset(%Bid{}, invalid_params)

    refute changeset.valid?
    assert "can't be blank" in errors_on(changeset).auction_id
  end

  test "rejects bid when bidder is seller", %{params: params} do
    invalid_params = Map.put(params.bid, :bidder_id, params.auction["seller_id"])
    changeset = Bid.changeset(%Bid{}, invalid_params)

    refute changeset.valid?
    assert "can't bid on the item you're selling" in errors_on(changeset).bidder_id
  end

  @tag :sleeps
  test "false unless end time is in the future", %{params: params} do
    duration = %Timex.Duration{megaseconds: 0, seconds: 1, microseconds: 0}
    end_time = Timex.add(DateTime.utc_now(), duration)
    closed_params = Map.put(params.auction, "end_auction_at", end_time)

    {:ok, closed_auction} = Auctions.insert(closed_params)

    :timer.sleep(1000)
    bid_params = Map.put(params.bid, :auction_id, closed_auction.id)
    changeset = Bid.changeset(%Bid{}, bid_params)

    refute changeset.valid?
    assert "auction is not open" in errors_on(changeset).amount
  end
end
