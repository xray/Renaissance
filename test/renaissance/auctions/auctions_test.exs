defmodule Renaissance.Test.AuctionsTest do
  use Renaissance.DataCase
  alias Renaissance.{Auction, Auctions, Users, Repo}

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
    end

    test "does not store when invalid seller_id" do
      invalid_seller_id = 0

      exception =
        assert_raise Ecto.ConstraintError, fn ->
          Auctions.create_auction(invalid_seller_id, @auction_two)
        end

      assert exception.message =~ "foreign_key_constraint"
    end
  end

  describe "closed?/1" do
    test "false when end time is in the future", %{user_id: seller_id} do
      {:ok, auction_created} = Auctions.create_auction(seller_id, @auction_one)
      assert Auctions.closed?(auction_created.id) == false
    end

    test "true when end time is in not the future", %{user_id: seller_id} do
      end_time =
        Timex.add(DateTime.utc_now(), %Timex.Duration{
          megaseconds: 0,
          seconds: 1,
          microseconds: 0
        })

      end_now_params = %{@auction_one | "end_auction_at" => end_time}
      end_now_params = Map.put(end_now_params, "seller_id", seller_id)
      {:ok, auction} = Repo.insert(Auction.changeset(%Auction{}, end_now_params))

      :timer.sleep(1000)
      assert Auctions.closed?(auction.id) == true
    end
  end
end
