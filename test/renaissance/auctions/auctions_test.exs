defmodule Renaissance.Test.AuctionsTest do
  use Renaissance.DataCase
  alias Renaissance.{Auctions, Users}

  setup _context do
    {:ok, user} = Users.insert(%{email: "test@suite.com", password: "password"})

    params_one = %{
      "title" => "Test Title",
      "description" => "Test description.",
      "end_auction_at" => %{day: "15", hour: "14", minute: "3", month: "4", year: "3019"},
      "price" => "10.00",
      "seller_id" => user.id
    }

    params_two =
      params_one
      |> Map.put("title", "Test Title Two")
      |> Map.put("description", "Test description two.")
      |> Map.put("price", "15.00")

    [
      params_one: params_one,
      params_two: params_two
    ]
  end

  describe "insert/1" do
    test "stores a valid auction in the db", %{params_one: params} do
      {:ok, new_auction} = Auctions.insert(params)

      assert new_auction.title == params["title"]
      assert new_auction.description == params["description"]
      assert Money.compare(new_auction.price, Money.new(10_00)) == 0
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
      end_time =
        Timex.add(DateTime.utc_now(), %Timex.Duration{
          megaseconds: 0,
          seconds: 1,
          microseconds: 0
        })

      {:ok, auction} = Auctions.insert(%{params | "end_auction_at" => end_time})

      :timer.sleep(1000)
      refute Auctions.open?(auction.id)
    end
  end

  describe "update/2" do
    test "updates a pre-existing auction description", %{params_one: params} do
      {:ok, auction} = Auctions.insert(params)

      auction_id = auction.id
      updated_description = "Updated Description"

      Auctions.update(auction_id, %{"description" => updated_description})

      retrieved_auction = Auctions.get!(auction_id)
      assert retrieved_auction.description == updated_description
    end

    test "updates a pre-existing auction title", %{params_one: params} do
      {:ok, auction} = Auctions.insert(params)

      auction_id = auction.id
      updated_title = "Updated Title"

      Auctions.update(auction_id, %{"title" => updated_title})

      retrieved_auction = Auctions.get!(auction_id)
      assert retrieved_auction.title == updated_title
    end
  end
end
