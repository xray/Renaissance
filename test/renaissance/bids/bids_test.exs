defmodule Renaissance.Test.BidsTest do
  use Renaissance.DataCase
  alias Renaissance.{Auctions, Bid, Bids, Users, Repo}

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
      {:error, changeset} = Bids.place_bid(Map.replace!(valid_params, "bidder_id", 0))

      assert "does not exist" in errors_on(changeset).bidder_id
      refute Repo.exists?(Bid)
    end

    test "does not place when invalid auction id", %{params: valid_params} do
      {:error, changeset} = Bids.place_bid(Map.replace!(valid_params, "auction_id", 0))

      assert "does not exist" in errors_on(changeset).auction_id
      refute Repo.exists?(Bid)
    end
  end

  describe "exists?/1" do
    test "true when bid with given id", %{params: valid_params} do
      {:ok, bid} = Bids.place_bid(valid_params)
      assert Bids.exists?(bid.id) == true
    end

    test "false when no bid with given id" do
      refute Bids.exists?(0)
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

    test "user can place back-to-back bids", %{params: valid_params} do
      auction_id = valid_params["auction_id"]

      Bids.place_bid(Map.replace!(valid_params, "amount", "8.01"))

      result_one = Bids.get_highest_bid(auction_id)
      assert Money.compare(result_one.amount, Money.new(8_01)) == 0

      Bids.place_bid(Map.replace!(valid_params, "amount", "10.05"))

      result_two = Bids.get_highest_bid(auction_id)
      assert Money.compare(result_two.amount, Money.new(10_05)) == 0

      Bids.place_bid(Map.replace!(valid_params, "amount", "10.00"))
      Bids.place_bid(Map.replace!(valid_params, "amount", "12.70"))

      result_three = Bids.get_highest_bid(auction_id)
      assert Money.compare(result_three.amount, Money.new(12_70)) == 0
    end
  end
end
