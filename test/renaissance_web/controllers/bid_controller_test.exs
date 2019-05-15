defmodule RenaissanceWeb.BidControllerTest do
  use RenaissanceWeb.ConnCase
  import Ecto.Query
  alias Renaissance.{Auctions, Repo, Users}
  alias Plug.Test

  @bidder_1_params %{email: "bidder1@bidder.com", password: "password"}
  @bidder_2_params %{email: "bidder2@bidder.com", password: "password"}

  @auction_params %{
    "title" => "Test Title",
    "description" => "Test description.",
    "end_auction_at" => %{day: 15, hour: 14, minute: 3, month: 4, year: 3019},
    "starting_amount" => "10.00"
  }

  def fixture(:auction) do
    {:ok, seller} = Users.insert(%{email: "seller@seller.com", password: "password"})

    {:ok, auction} =
      @auction_params
      |> Map.put("seller_id", seller.id)
      |> Auctions.insert()

    auction
  end

  describe "create/2" do
    setup do
      {:ok, bidder} = Users.insert(@bidder_1_params)

      {:ok, conn: Test.init_test_session(build_conn(), current_user_id: bidder.id)}
    end

    test "places a bid on an auction", %{conn: conn} do
      auction = fixture(:auction)

      bid_params = %{
        auction_id: auction.id,
        bidder_id: Plug.Conn.get_session(conn, :current_user_id),
        amount: "11.00"
      }

      result = post(conn, "/bids", bid_params)

      assert get_flash(result, :info) == "Bid Placed!"
      assert redirected_to(result, 302) == "/auctions/#{auction.id}"
    end

    test "doesn't place bid that is under current price", %{conn: conn} do
      auction = fixture(:auction)

      bid_params = %{
        auction_id: auction.id,
        bidder_id: Plug.Conn.get_session(conn, :current_user_id),
        amount: "9"
      }

      result = post(conn, "/bids", bid_params)

      assert get_flash(result, :error) == "must be greater than $10.00"
      assert redirected_to(result, 302) == "/auctions/#{auction.id}"
    end
  end

  describe "concurrent_bids" do
    setup do
      auction = fixture(:auction)

      {:ok, bidder_1} = Users.insert(@bidder_1_params)
      {:ok, bidder_2} = Users.insert(@bidder_2_params)

      bidder_1_conn =
        build_conn()
        |> Test.init_test_session(current_user_id: bidder_1.id)

      bidder_2_conn =
        build_conn()
        |> Test.init_test_session(current_user_id: bidder_2.id)

      {:ok, auction: auction, bidder_1_conn: bidder_1_conn, bidder_2_conn: bidder_2_conn}
    end

    test "doesn't place multiple bids at the same price", context do
      auction_id = context[:auction].id

      bid_1 =
        Task.async(fn ->
          context[:bidder_1_conn]
          |> post("/bids", %{auction_id: auction_id, amount: "11"})
        end)

      bid_2 =
        Task.async(fn ->
          context[:bidder_2_conn]
          |> post("/bids", %{auction_id: auction_id, amount: "11"})
        end)

      Task.await(bid_1)
      Task.await(bid_2)

      refute Ecto.assoc(context[:auction], :bids)
             |> Repo.all()
             |> Enum.map(&Map.get(&1, :amount)) ==
               [
                 %Money{amount: 1100, currency: :USD},
                 %Money{amount: 1100, currency: :USD}
               ]
    end

    test "requires bid to be greater than current price", context do
      auction_id = context[:auction].id

      bid_1 =
        Task.async(fn ->
          context[:bidder_1_conn]
          |> post("/bids", %{auction_id: auction_id, amount: "11"})
          |> get_flash(:error)
        end)

      bid_2 =
        Task.async(fn ->
          context[:bidder_2_conn]
          |> post("/bids", %{auction_id: auction_id, amount: "11"})
          |> get_flash(:error)
        end)

      flash_1 = Task.await(bid_1)
      flash_2 = Task.await(bid_2)

      assert "must be greater than $11.00" in [flash_1, flash_2]
    end

    test "bid history should be always increasing in price", context do
      auction_id = context[:auction].id

      context[:bidder_1_conn]
      |> post("/bids", %{auction_id: auction_id, amount: "12"})

      bid_1 =
        Task.async(fn ->
          context[:bidder_1_conn]
          |> post("/bids", %{auction_id: auction_id, amount: "14"})
        end)

      bid_2 =
        Task.async(fn ->
          context[:bidder_2_conn]
          |> post("/bids", %{auction_id: auction_id, amount: "13"})
        end)

      Task.await(bid_1)
      Task.await(bid_2)

      refute Ecto.assoc(context[:auction], :bids)
             |> order_by(asc: :created_at)
             |> Repo.all()
             |> Enum.map(&Map.get(&1, :amount)) == [
               %Money{amount: 1200, currency: :USD},
               %Money{amount: 1400, currency: :USD},
               %Money{amount: 1300, currency: :USD}
             ]
    end
  end
end
