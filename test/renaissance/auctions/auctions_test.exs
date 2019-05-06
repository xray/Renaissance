defmodule Renaissance.Test.AuctionsTest do
  use Renaissance.DataCase
  alias Renaissance.{Auction, Auctions, Repo, Users}

  @valid_end %{
    day: "15",
    hour: "14",
    minute: "3",
    month: "4",
    year: "3019"
  }

  @auction_one %{
    "title" => "Test Title",
    "description" => "Test description.",
    "end_auction_at" => @valid_end,
    "price" => "10.00"
  }

  @auction_two %{
    "title" => "Test Title Two",
    "description" => "Test description two.",
    "end_auction_at" => @valid_end,
    "price" => "15.00"
  }

  setup _context do
    user_params = %{email: "test@suite.com", password: "password"}
    {:ok, user} = Users.register_user(user_params)
    [user_id: user.id]
  end

  describe "create_auction/2" do
    test "stores a valid auction in the db", %{user_id: seller_id} do
      {:ok, new_auction} = Auctions.create_auction(seller_id, @auction_one)

      assert new_auction.title == @auction_one["title"]
      assert new_auction.description == @auction_one["description"]
      assert Money.compare(new_auction.price, Money.new(10_00)) == 0
    end

    test "does not store when title is blank", %{user_id: seller_id} do
      invalid_params = %{@auction_two | "title" => ""}
      assert {:error, _} = Auctions.create_auction(seller_id, invalid_params)
      refute Repo.exists?(Auction)
    end

    test "does not store when invalid seller_id" do
      {:error, changeset} = Auctions.create_auction(0, @auction_two)

      assert "does not exist" in errors_on(changeset).seller_id
      refute Repo.exists?(Auction)
    end
  end

  describe "exists?/1" do
    test "true when auction with given id", %{user_id: seller_id} do
      {:ok, auction} = Auctions.create_auction(seller_id, @auction_one)
      assert Auctions.exists?(auction.id)
    end

    test "false when no auction with given id" do
      refute Auctions.exists?(0)
    end
  end

  describe "open?/1" do
    test "true when end time is in the future", %{user_id: seller_id} do
      {:ok, auction_created} = Auctions.create_auction(seller_id, @auction_one)
      assert Auctions.open?(auction_created.id)
    end

    test "nil when auction does not exist" do
      assert is_nil(Auctions.open?(0))
    end

    test "false when end time is in not the future", %{user_id: seller_id} do
      end_time =
        Timex.add(DateTime.utc_now(), %Timex.Duration{
          megaseconds: 0,
          seconds: 1,
          microseconds: 0
        })

      end_now_params =
        %{@auction_one | "end_auction_at" => end_time}
        |> Map.put("seller_id", seller_id)

      {:ok, auction} = Repo.insert(Auction.changeset(%Auction{}, end_now_params))

      :timer.sleep(1000)
      refute Auctions.open?(auction.id)
    end
  end
end
