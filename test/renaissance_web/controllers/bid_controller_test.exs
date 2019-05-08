defmodule RenaissanceWeb.BidControllerTest do
  use RenaissanceWeb.ConnCase
  alias Renaissance.{Auction, Auctions, Users, Repo}
  alias Plug.Test

  @valid_end %{
    day: 15,
    hour: 14,
    minute: 3,
    month: 4,
    year: 3019
  }

  @valid_auction %{
    "title" => "Test Title",
    "description" => "Test description.",
    "end_auction_at" => @valid_end,
    "price" => "10.00"
  }

  describe "create/2" do
    setup %{conn: conn} do
      seller_params = %{email: "seller@seller.com", password: "password"}
      {:ok, user_seller} = Users.insert(seller_params)
      Auctions.insert(user_seller.id, @valid_auction)

      bidder_params = %{email: "bidder@bidder.com", password: "password"}
      {:ok, user_bidder} = Users.insert(bidder_params)

      {:ok, conn: Test.init_test_session(conn, current_user_id: user_bidder.id)}
    end

    test "places a bid on an auction", %{conn: conn} do
      auction_id = Repo.get_by(Auction, title: @valid_auction["title"]).id
      user_id = Plug.Conn.get_session(conn, :current_user_id)

      result =
        conn
        |> post("/bid", %{
          auction_id: Integer.to_string(auction_id),
          bidder_id: user_id,
          amount: "11.00"
        })

      assert get_flash(result, :info) == "Bid Placed!"
      assert redirected_to(result, 302) == "/auctions/#{auction_id}"
    end
  end
end
