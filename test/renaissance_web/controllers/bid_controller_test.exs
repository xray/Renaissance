defmodule RenaissanceWeb.BidControllerTest do
  use RenaissanceWeb.ConnCase
  alias Renaissance.{Auction, Auctions, Users, Repo}
  alias Plug.Test

  @valid_auction %{
    "title" => "Test Title",
    "description" => "Test description.",
    "end_auction_at" => %{day: 15, hour: 14, minute: 3, month: 4, year: 3019},
    "price" => "10.00"
  }

  describe "create/2" do
    setup %{conn: conn} do
      {:ok, bidder} = Users.insert(%{email: "bidder@bidder.com", password: "password"})
      {:ok, seller} = Users.insert(%{email: "seller@seller.com", password: "password"})
      Auctions.insert(Map.put(@valid_auction, "seller_id", seller.id))

      {:ok, conn: Test.init_test_session(conn, current_user_id: bidder.id)}
    end

    test "places a bid on an auction", %{conn: conn} do
      auction_id = Repo.get_by(Auction, title: @valid_auction["title"]).id

      bid_params = %{
        auction_id: Integer.to_string(auction_id),
        bidder_id: Plug.Conn.get_session(conn, :current_user_id),
        amount: "11.00"
      }

      result = post(conn, "/bids", bid_params)

      assert get_flash(result, :info) == "Bid Placed!"
      assert redirected_to(result, 302) == "/auctions/#{auction_id}"
    end

    test "doesn't place bid that is under current price", %{conn: conn} do
      auction_id = Repo.get_by(Auction, title: @valid_auction["title"]).id

      bid_params = %{
        auction_id: Integer.to_string(auction_id),
        bidder_id: Plug.Conn.get_session(conn, :current_user_id),
        amount: "9"
      }

      result = post(conn, "/bids", bid_params)

      assert get_flash(result, :error) == "must be greater than $10.00"
      assert redirected_to(result, 302) == "/auctions/#{auction_id}"
    end
  end
end
