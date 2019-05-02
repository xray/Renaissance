defmodule Renaissance.Test.BidsTest do
  use Renaissance.DataCase
  alias Renaissance.{Auctions, Users, Bids}

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
      params: %{
        "bidder_id" => bidder.id,
        "auction_id" => auction.id,
        "amount" => "1.01"
      }
    ]
  end

  describe "place_bid/1" do
    test "places a valid bid", %{params: valid_params} do
      {:ok, new_bid} = Bids.place_bid(valid_params)

      assert new_bid.bidder_id == valid_params["bidder_id"]
      assert new_bid.auction_id == valid_params["auction_id"]
      assert Money.compare(new_bid.amount, Money.new(1_01)) == 0
    end

    test "does not place when invalid bidder id", %{params: valid_params} do
      exception =
        assert_raise Ecto.ConstraintError, fn ->
          Bids.place_bid(Map.replace!(valid_params, "bidder_id", 0))
        end

      assert exception.constraint == "bids_bidder_id_fkey"
    end

    test "does not place when invalid auction id", %{params: valid_params} do
      exception =
        assert_raise Ecto.ConstraintError, fn ->
          Bids.place_bid(Map.replace!(valid_params, "auction_id", 0))
        end

      assert exception.constraint == "bids_auction_id_fkey"
    end
  end

  describe "get_highest_bid/1" do
    test "returns nil if no bids exist for the given auction", %{params: valid_params} do
      result = Bids.get_highest_bid(valid_params["auction_id"])
      assert is_nil(result)
    end

    test "details the highest existing bid for the given auction", %{params: valid_params} do
      Bids.place_bid(Map.replace!(valid_params, "amount", "10.05"))
      Bids.place_bid(Map.replace!(valid_params, "amount", "10.00"))

      result = Bids.get_highest_bid(valid_params["auction_id"])

      assert Money.compare(result.amount, Money.new(10_05)) == 0
      assert result.bidder_id == valid_params["bidder_id"]
    end
  end
end