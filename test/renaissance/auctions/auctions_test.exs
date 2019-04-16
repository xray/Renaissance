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

  @user_params %{email: "test@suite.com", password: "password"}

  @second_auction %{
    "auction" => %{
      "title" => "Test Two Title",
      "description" => "Test two description.",
      "end_date_day" => "3019-04-15",
      "end_date_time" => "14:03",
      "price" => "15.00"
    }
  }

  describe "auctions" do
    test "stores a valid auction in the db" do
      Users.register_user(@user_params)
      Auctions.create_auction(@user_params.email, @valid_attrs)

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

      Users.register_user(%{email: @user_params.email, password: "password"})

      Auctions.create_auction(@user_params.email, changeset)

      count = Repo.aggregate(Ecto.Query.from(p in "auctions"), :count, :id)
      assert 0 == count
    end

    test "returns a list of auctions" do
      user_email = "test@suite.com"
      Users.register_user(%{email: user_email, password: "password"})
      Auctions.create_auction(user_email, @valid_attrs)
      Auctions.create_auction(user_email, @second_auction)

      auctions = Auctions.get_all_auctions()

      assert Enum.at(auctions, 0).title == @valid_attrs["auction"]["title"]
      assert Enum.at(auctions, 0).description == @valid_attrs["auction"]["description"]
      assert Enum.at(auctions, 0).end_date == "3019-04-15 19:03:00Z"
      assert Enum.at(auctions, 0).seller == "test@suite.com"
      assert Enum.at(auctions, 0).price == "$10.00"
      assert Enum.at(auctions, 1).title == @second_auction["auction"]["title"]
      assert Enum.at(auctions, 1).description == @second_auction["auction"]["description"]
      assert Enum.at(auctions, 1).end_date == "3019-04-15 19:03:00Z"
      assert Enum.at(auctions, 1).seller == "test@suite.com"
      assert Enum.at(auctions, 1).price == "$15.00"
    end
  end
end
