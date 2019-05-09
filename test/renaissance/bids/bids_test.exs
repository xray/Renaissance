defmodule Renaissance.Test.BidsTest do
  use Renaissance.DataCase
  alias Renaissance.{Auctions, Bid, Bids, Helpers, Repo, Users}

  setup _context do
    {:ok, seller} = Users.insert(%{email: "seller@mail.com", password: "password"})
    {:ok, bidder} = Users.insert(%{email: "bidder@mail.com", password: "password"})

    end_time = %{"day" => 15, "hour" => 14, "minute" => 3, "month" => 4, "year" => 3019}

    {:ok, auction} =
      Auctions.insert(%{
        "title" => "Test Title",
        "description" => "Test description.",
        "end_auction_at" => end_time,
        "price" => "1.00",
        "seller_id" => seller.id
      })

    [params: %{"bidder_id" => bidder.id, "auction_id" => auction.id, "amount" => "1.01"}]
  end

  describe "insert/1" do
    test "inserts a valid bid", %{params: bid_params} do
      {:ok, new_bid} = Bids.insert(bid_params)

      assert new_bid.bidder_id == bid_params["bidder_id"]
      assert new_bid.auction_id == bid_params["auction_id"]
      assert Money.compare(new_bid.amount, Money.new(1_01)) == 0
    end

    test "does not insert bid  when invalid bidder id", %{params: bid_params} do
      {:error, changeset} = Bids.insert(Map.replace!(bid_params, "bidder_id", 0))

      assert "does not exist" in errors_on(changeset).bidder_id
      refute Repo.exists?(Bid)
    end

    test "does not insert bid when invalid auction id", %{params: bid_params} do
      {:error, changeset} = Bids.insert(Map.replace!(bid_params, "auction_id", 0))

      assert "does not exist" in errors_on(changeset).auction_id
      refute Repo.exists?(Bid)
    end
  end

  describe "exists?/1" do
    test "true when bid with given id", %{params: bid_params} do
      {:ok, bid} = Bids.insert(bid_params)
      assert Bids.exists?(bid.id) == true
    end

    test "false when no bid with given id" do
      refute Bids.exists?(0)
    end
  end

  describe "get_highest_bid/1" do
    @eight_oh_one %{string: "8.01", money: Money.new(8_01)}
    @ten_dollars %{string: "10.00", money: Money.new(10_00)}
    @ten_oh_five %{string: "10.05", money: Money.new(10_05)}
    @twelve_seventy %{string: "12.70", money: Money.new(12_70)}

    def place_bid(bid_params, amount) do
      Map.replace!(bid_params, "amount", amount.string) |> Bids.insert()
    end

    def assert_equal(actual, expected) do
      assert Helpers.Money.compare(actual.amount, expected.money) == :eq
    end

    test "returns nil if no bids exist for the given auction", %{params: bid_params} do
      result = Bids.get_highest_bid(bid_params["auction_id"])
      assert is_nil(result)
    end

    test "details the highest existing bid for the given auction", %{params: bid_params} do
      bid_params |> place_bid(@ten_dollars)
      bid_params |> place_bid(@ten_oh_five)

      result = Bids.get_highest_bid(bid_params["auction_id"])

      assert_equal(result, @ten_oh_five)
      assert result.bidder_id == bid_params["bidder_id"]
    end

    test "user can place back-to-back bids", %{params: bid_params} do
      auction_id = bid_params["auction_id"]

      bid_params |> place_bid(@eight_oh_one)

      Bids.get_highest_bid(auction_id)
      |> assert_equal(@eight_oh_one)

      bid_params |> place_bid(@ten_oh_five)

      Bids.get_highest_bid(auction_id)
      |> assert_equal(@ten_oh_five)

      bid_params |> place_bid(@ten_dollars)
      bid_params |> place_bid(@twelve_seventy)

      Bids.get_highest_bid(auction_id)
      |> assert_equal(@twelve_seventy)
    end

    @tag :sleeps
    test "returns earliest bid when multiple valid [highest] bids", %{params: bid_params} do
      auction_id = bid_params["auction_id"]

      bid_params |> place_bid(@eight_oh_one)

      bidder_1_id = bid_params["bidder_id"]
      {:ok, bidder_2} = Users.insert(%{email: "bidder2@mail.com", password: "password2"})
      {:ok, bidder_3} = Users.insert(%{email: "bidder3@mail.com", password: "password3"})

      :timer.sleep(100)
      bid_params |> Map.replace!("bidder_id", bidder_2.id) |> place_bid(@eight_oh_one)

      :timer.sleep(400)
      bid_params |> Map.replace!("bidder_id", bidder_3.id) |> place_bid(@eight_oh_one)

      result = Bids.get_highest_bid(auction_id)

      assert_equal(result, @eight_oh_one)
      assert result.bidder_id == bidder_1_id
    end
  end
end
