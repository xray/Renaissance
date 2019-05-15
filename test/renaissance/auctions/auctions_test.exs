defmodule Renaissance.Test.AuctionsTest do
  use Renaissance.DataCase
  alias Renaissance.{Auctions, Helpers, Users, Bids}

  setup _context do
    {:ok, user} = Users.insert(%{email: "test@suite.com", password: "password"})

    params_one = %{
      "title" => "Test Title",
      "description" => "Test description.",
      "end_auction_at" => %{day: "15", hour: "14", minute: "3", month: "4", year: "3019"},
      "starting_amount" => "10.00",
      "seller_id" => user.id
    }

    params_two =
      params_one
      |> Map.put("title", "Test Title Two")
      |> Map.put("description", "Test description two.")
      |> Map.put("starting_amount", "15.00")

    [params_one: params_one, params_two: params_two]
  end

  def assert_amount_equal(actual, expected) do
    assert Helpers.Money.compare(actual, expected) == :eq
  end

  describe "insert/1" do
    test "stores a valid auction in the db", %{params_one: params} do
      {:ok, auction} = Auctions.insert(params)

      assert auction.title == params["title"]
      assert auction.description == params["description"]

      assert_amount_equal(auction.starting_amount, Money.new(10_00))
    end

    test "does not store when title is blank", %{params_two: params} do
      invalid_params = %{params | "title" => ""}
      assert {:error, _} = Auctions.insert(invalid_params)
    end

    test "does not store when invalid seller_id", %{params_two: params} do
      invalid_params = Map.put(params, "seller_id", 0)
      {:error, changeset} = Auctions.insert(invalid_params)

      assert "does not exist" in errors_on(changeset).seller_id
    end
  end

  describe "exists?/1" do
    test "true when auction with given id", %{params_one: params} do
      {:ok, auction} = Auctions.insert(params)
      assert Auctions.exists?(auction.id)
    end

    test "false when no auction with given id" do
      refute Auctions.exists?(0)
    end
  end

  describe "open?/1" do
    test "true when end time is in the future", %{params_one: params} do
      {:ok, auction} = Auctions.insert(params)
      assert Auctions.open?(auction.id)
    end

    test "false when auction does not exist" do
      assert Auctions.open?(0) == false
    end

    @tag :sleeps
    test "false when end time is in not the future", %{params_one: params} do
      duration = %Timex.Duration{megaseconds: 0, seconds: 1, microseconds: 0}
      end_time = Timex.add(DateTime.utc_now(), duration)
      closed_params = Map.put(params, "end_auction_at", end_time)

      {:ok, closed_auction} = Auctions.insert(closed_params)

      :timer.sleep(1000)
      refute Auctions.open?(closed_auction.id)
    end
  end

  describe "update/2" do
    @updates %{description: "Updated Description", title: "Updated Title"}
    test "updates a pre-existing auction description", %{params_one: params} do
      {:ok, auction} = Auctions.insert(params)

      Auctions.update(auction.id, %{"description" => @updates.description})

      actual = auction.id |> Auctions.get!() |> Map.get(:description)
      assert actual == @updates.description
    end

    test "updates a pre-existing auction title", %{params_one: params} do
      {:ok, auction} = Auctions.insert(params)

      Auctions.update(auction.id, %{"title" => @updates.title})

      actual = auction.id |> Auctions.get!() |> Map.get(:title)
      assert actual == @updates.title
    end
  end

  describe "get_won_auctions/1 & get_open_auctions/0" do
    setup _context do
      {:ok, seller} = Users.insert(%{email: "seller@mail.com", password: "password"})
      {:ok, bidder} = Users.insert(%{email: "bidder@mail.com", password: "password"})

      duration_one_sec = %Timex.Duration{megaseconds: 0, seconds: 1, microseconds: 0}
      end_time_now = Timex.add(DateTime.utc_now(), duration_one_sec)

      duration_twenty_four_hours = %Timex.Duration{megaseconds: 0, seconds: 86400, microseconds: 0}
      end_time_future = Timex.add(DateTime.utc_now(), duration_twenty_four_hours)

      params_now = %{
        "title" => "Test Title",
        "description" => "Test description.",
        "end_auction_at" => end_time_now,
        "starting_amount" => "4.00",
        "seller_id" => seller.id
      }

      params_future =
        params_now
        |> Map.put("title", "Test Title Two")
        |> Map.put("description", "Test description two.")
        |> Map.put("end_auction_at", end_time_future)
        |> Map.put("starting_amount", "6.00")

      {:ok, auction_past} =
        Auctions.insert(params_now)
      {:ok, auction_future} =
        Auctions.insert(params_future)

      bid_params = %{"bidder_id" => bidder.id, "auction_id" => auction_past.id, "amount" => "1.00"}

      [bid_params: bid_params, past: auction_past, future: auction_future]
    end

    @eight_dollars %{string: "8.00", money: Money.new(8_00)}

    def place_bid(bid_params, amount) do
      bid_params |> Map.replace!("amount", amount.string) |> Bids.insert()
    end

    @tag :sleeps
    test "get_won_auctions/1 returns a list of auctions won by the user", %{bid_params: bid_params, past: auction_past, future: _auction_future} do
      bid_params |> place_bid(@eight_dollars)

      :timer.sleep(1000)

      won_auctions = Auctions.get_won_auctions(bid_params["bidder_id"])
      auction = hd(won_auctions)

      assert Enum.count(won_auctions) == 1
      assert auction.title == auction_past.title
      assert auction.id == auction_past.id
      assert auction.description == auction_past.description
    end

    @tag :sleeps
    test "get_open_auctions/0 returns a list of open auctions", %{bid_params: bid_params, past: _auction_past, future: auction_future} do
      bid_params |> place_bid(@eight_dollars)

      :timer.sleep(1000)

      open_auctions = Auctions.get_open_auctions()
      auction = hd(open_auctions)

      assert Enum.count(open_auctions) == 1
      assert auction.title == auction_future.title
      assert auction.id == auction_future.id
      assert auction.description == auction_future.description
    end
  end
end
