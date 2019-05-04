defmodule Renaissance.Test.BidTest do
  use Renaissance.DataCase
  alias Renaissance.{Auctions, Bid, Users}

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
      seller_id: seller.id,
      params: %{
        bidder_id: bidder.id,
        auction_id: auction.id,
        amount: 101
      }
    ]
  end

  test "accepts an initial valid auction bid", %{params: valid_params} do
    changeset = Bid.changeset(%Bid{}, valid_params)
    assert changeset.valid?
  end

  test "rejects bid with non-positive amount", %{params: valid_params} do
    invalid_params = %{valid_params | amount: -100}
    changeset = Bid.changeset(%Bid{}, invalid_params)

    refute changeset.valid?

    message = ~s(must be greater than $#{@auction_params["price"]})
    assert message in errors_on(changeset).amount
  end

  test "rejects bid unless amount exceeds current", %{params: valid_params} do
    invalid_params = %{valid_params | amount: 1}
    changeset = Bid.changeset(%Bid{}, invalid_params)

    refute changeset.valid?

    message = ~s(must be greater than $#{@auction_params["price"]})
    assert message in errors_on(changeset).amount
  end

  test "rejects bid with no bidder_id", %{params: valid_params} do
    invalid_params = %{valid_params | bidder_id: nil}
    changeset = Bid.changeset(%Bid{}, invalid_params)

    refute changeset.valid?
    assert "can't be blank" in errors_on(changeset).bidder_id
  end

  test "rejects bid with no auction_id", %{params: valid_params} do
    invalid_params = %{valid_params | auction_id: nil}
    changeset = Bid.changeset(%Bid{}, invalid_params)

    refute changeset.valid?
    assert "can't be blank" in errors_on(changeset).auction_id
  end

  test "rejects bid when bidder is seller", %{params: valid_params, seller_id: seller_id} do
    invalid_params = %{valid_params | bidder_id: seller_id}
    changeset = Bid.changeset(%Bid{}, invalid_params)

    refute changeset.valid?
    assert "can't bid on auction item that you're selling" in errors_on(changeset).bidder_id
  end

  test "false when end time is not in the future", %{params: valid_params, seller_id: seller_id} do
    end_time =
      Timex.add(DateTime.utc_now(), %Timex.Duration{
        megaseconds: 0,
        seconds: 1,
        microseconds: 0
      })

    closed_params =
      @auction_params
      |> Map.put("end_auction_at", end_time)
      |> Map.put("seller_id", seller_id)

    {:ok, closed_auction} = Auctions.create_auction(seller_id, closed_params)

    :timer.sleep(1000)
    params = %{valid_params | auction_id: closed_auction.id}
    changeset = Bid.changeset(%Bid{}, params)

    refute changeset.valid?
    assert "auction is not open" in errors_on(changeset).amount
  end
end
