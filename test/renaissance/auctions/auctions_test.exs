defmodule Renaissance.Test.AuctionsTest do
  use Renaissance.DataCase
  alias Renaissance.{Auctions, Auction, Users, Repo}

  @end_date_time %{
    "day" => "15",
    "hour" => "14",
    "minute" => "3",
    "month" => "4",
    "year" => "3019"
  }

  @auction_one %{
    "title" => "Test Title",
    "description" => "Test description.",
    "end_auction_at" => @end_date_time,
    "price" => "10.00"
  }

  @user_params %{email: "test@suite.com", password: "password"}

  @auction_two %{
    "title" => "Test Two Title",
    "description" => "Test two description.",
    "end_auction_at" => @end_date_time,
    "price" => "15.00"
  }

  describe "auctions" do
    test "stores a valid auction in the db" do
      Users.register_user(@user_params)
      Auctions.create_auction(@user_params.email, @auction_one)

      auction = Repo.get_by(Auction, title: "Test Title")
      assert auction.title == @auction_one["title"]
      assert auction.description == @auction_one["description"]
      assert Money.compare(auction.price, Money.new(10_00, :USD)) == 0
    end

    test "does not store an invalid changeset" do
      Users.register_user(@user_params)

      invalid_params = Map.put(@auction_two, "title", "")
      Auctions.create_auction(@user_params.email, invalid_params)

      count = Repo.aggregate(Ecto.Query.from(p in "auctions"), :count, :id)
      assert 0 == count
    end

    test "returns a list of auctions" do
      Users.register_user(@user_params)
      Auctions.create_auction(@user_params.email, @auction_one)
      Auctions.create_auction(@user_params.email, @auction_two)

      auctions = Auctions.get_all_auctions()

      assert Enum.at(auctions, 0).title == @auction_one["title"]
      assert Enum.at(auctions, 0).description == @auction_one["description"]
      assert Enum.at(auctions, 0).end_auction_at == "3019-04-15 14:03:00Z"
      assert Enum.at(auctions, 0).seller == "test@suite.com"
      assert Enum.at(auctions, 0).price == "$10.00"
      assert Enum.at(auctions, 1).title == @auction_two["title"]
      assert Enum.at(auctions, 1).description == @auction_two["description"]
      assert Enum.at(auctions, 1).end_auction_at == "3019-04-15 14:03:00Z"
      assert Enum.at(auctions, 1).seller == "test@suite.com"
      assert Enum.at(auctions, 1).price == "$15.00"
    end
  end
end
