defmodule Renaissance.Test.BidTest do
  use Renaissance.DataCase
  alias Renaissance.{Auctions, Users, Bid}

  def fixture(:user) do
    user_params = %{email: "test@suite.com", password: "password"}
    {:ok, user} = Users.register_user(user_params)
    user
  end

  def fixture(:auction, user_id) do
    auction_params = %{
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

    {:ok, auction} = Auctions.create_auction(user_id, auction_params)
    auction
  end

  test "accepts an initial valid auction bid" do
    bidder_id = fixture(:user).id
    auction_id = fixture(:auction, bidder_id).id
    valid_params = %{bidder_id: bidder_id, auction_id: auction_id, amount: "01.01"}

    changeset = Bid.changeset(%Bid{}, valid_params)
    assert changeset.valid?
  end
end
