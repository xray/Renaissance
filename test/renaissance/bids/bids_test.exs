defmodule Renaissance.Test.BidsTest do
  use Renaissance.DataCase
  alias Renaissance.{Auctions, Bid, Bids, Helpers, Repo, Users}

  def assert_amount_equal(actual, expected) do
    assert Helpers.Money.compare(actual, expected) == :eq
  end

  setup _context do
    {:ok, seller} = Users.insert(%{email: "seller@mail.com", password: "password"})
    {:ok, bidder} = Users.insert(%{email: "bidder@mail.com", password: "password"})

    end_time = %{"day" => 15, "hour" => 14, "minute" => 3, "month" => 4, "year" => 3019}

    {:ok, auction} =
      Auctions.insert(%{
        "title" => "Test Title",
        "description" => "Test description.",
        "end_auction_at" => end_time,
        "starting_amount" => "1.00",
        "seller_id" => seller.id
      })

    [params: %{"bidder_id" => bidder.id, "auction_id" => auction.id, "amount" => "1.01"}]
  end

  describe "insert/1" do
    test "inserts a valid bid", %{params: bid_params} do
      {:ok, bid} = Bids.insert(bid_params)

      assert bid.bidder_id == bid_params["bidder_id"]
      assert bid.auction_id == bid_params["auction_id"]

      assert_amount_equal(bid.amount, Money.new(1_01))
    end

    test "does not insert bid when invalid bidder id", %{params: bid_params} do
      {:error, changeset} = Map.replace!(bid_params, "bidder_id", 0) |> Bids.insert()

      assert "An error occured, your bid was not placed." in errors_on(changeset).auction
      refute Repo.exists?(Bid)
    end

    test "does not insert bid when invalid auction id", %{params: bid_params} do
      {:error, changeset} = Map.replace!(bid_params, "auction_id", 0) |> Bids.insert()

      assert "An error occured, your bid was not placed." in errors_on(changeset).auction
      refute Repo.exists?(Bid)
    end
  end

  describe "exists?/1" do
    test "true when bid with given id", %{params: bid_params} do
      {:ok, bid} = Bids.insert(bid_params)
      assert Bids.exists?(bid.id)
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
      bid_params |> Map.replace!("amount", amount.string) |> Bids.insert()
    end

    def get_highest(auction_id), do: Bids.get_highest_bid(auction_id)

    test "returns nil if no bids exist for the auction", %{params: bid_params} do
      highest = bid_params["auction_id"] |> get_highest()
      assert is_nil(highest)
    end

    test "details current highest bid for the auction", %{params: bid_params} do
      bid_params |> place_bid(@ten_dollars)
      bid_params |> place_bid(@ten_oh_five)

      highest = get_highest(bid_params["auction_id"])

      assert_amount_equal(highest.amount, @ten_oh_five.money)
      assert highest.bidder_id == bid_params["bidder_id"]
    end

    test "user can place back-to-back bids", %{params: bid_params} do
      id = bid_params["auction_id"]

      bid_params |> place_bid(@eight_oh_one)
      assert_amount_equal(get_highest(id).amount, @eight_oh_one.money)

      bid_params |> place_bid(@ten_oh_five)
      assert_amount_equal(get_highest(id).amount, @ten_oh_five.money)

      bid_params |> place_bid(@ten_dollars)
      bid_params |> place_bid(@twelve_seventy)
      assert_amount_equal(get_highest(id).amount, @twelve_seventy.money)
    end

    @tag :sleeps
    test "returns earliest bid when multiple valid [highest] bids", %{params: bid_params} do
      auction_id = bid_params["auction_id"]
      {:ok, bidder_2} = Users.insert(%{email: "bidder2@mail.com", password: "password2"})
      {:ok, bidder_3} = Users.insert(%{email: "bidder3@mail.com", password: "password3"})

      bid_params |> place_bid(@eight_oh_one)

      :timer.sleep(100)
      bid_params |> Map.replace!("bidder_id", bidder_2.id) |> place_bid(@eight_oh_one)

      :timer.sleep(400)
      bid_params |> Map.replace!("bidder_id", bidder_3.id) |> place_bid(@eight_oh_one)

      highest = get_highest(auction_id)

      assert_amount_equal(highest.amount, @eight_oh_one.money)
      assert highest.bidder_id == bid_params["bidder_id"]
    end
  end
end
