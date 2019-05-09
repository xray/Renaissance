defmodule RenaissanceWeb.BidControllerTest do
  use RenaissanceWeb.ConnCase
  alias Renaissance.{Auction, Auctions, Repo, Users}
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

  describe "concurrent_bids" do
    test "doesn't place multiple bids at the same price", %{conn: conn} do
      {:ok, seller} =
        Users.insert(%{
          email: "seller@seller.com",
          password: "password"
        })

      {:ok, auction} = Auctions.insert(Map.put(@valid_auction, "seller_id", seller.id))

      {:ok, bidder_1} =
        Users.insert(%{
          email: "bidder1@bidder.com",
          password: "password"
        })

      {:ok, bidder_2} =
        Users.insert(%{
          email: "bidder2@bidder.com",
          password: "password"
        })

      bidder_1_conn = Test.init_test_session(conn, current_user_id: bidder_1.id)
      bidder_2_conn = Test.init_test_session(conn, current_user_id: bidder_2.id)

      bid_1 =
        Task.async(fn ->
          bidder_1_conn
          |> post("/bids", %{
            auction_id: Integer.to_string(auction.id),
            amount: "11"
          })
        end)

      bid_2 =
        Task.async(fn ->
          bidder_2_conn
          |> post("/bids", %{
            auction_id: Integer.to_string(auction.id),
            amount: "11"
          })
        end)

      Task.await(bid_1)
      Task.await(bid_2)

      refute Ecto.assoc(auction, :bids) |> Repo.all() |> Enum.map(&Map.get(&1, :amount)) == [
               %Money{amount: 1100, currency: :USD},
               %Money{amount: 1100, currency: :USD}
             ]
    end
  end
end
