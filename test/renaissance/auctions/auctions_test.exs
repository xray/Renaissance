defmodule Renaissance.Test.AuctionsTest do
  use Renaissance.DataCase
  alias Renaissance.{Auctions, Auction, Users, Repo}

  @valid_attrs %{
    "auction" => %{
      "title" => "Test Title",
      "description" => "Test description.",
      "end_date_day" => "3019-04-15",
      "end_date_time" => "14:03",
      "price" => "10.00"
    }
  }

  describe "auctions" do
    test "stores a valid auction in the db" do
      user_email = "test@suite.com"
      Users.register_user(%{email: user_email, password: "password"})

      Auctions.create_auction(user_email, @valid_attrs)

      auction = Repo.get_by(Auction, title: "Test Title")
      assert auction.title == @valid_attrs["auction"]["title"]
      assert auction.description == @valid_attrs["auction"]["description"]
      assert Money.compare(auction.price, Money.new(10_00, :USD)) == 0
    end

    test "does not store an invalid changeset" do
      changeset = %{
        "auction" => %{
          "title" => "",
          "description" => "Test description.",
          "end_date_day" => "3019-04-15",
          "end_date_time" => "14:03",
          "price" => "10.00"
        }
      }

      user_email = "test@suite.com"
      Users.register_user(%{email: user_email, password: "password"})

      Auctions.create_auction(user_email, changeset)

      count = Repo.aggregate(Ecto.Query.from(p in "auctions"), :count, :id)
      assert 0 == count
    end
  end
end
