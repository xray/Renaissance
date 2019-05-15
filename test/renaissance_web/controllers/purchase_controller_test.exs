defmodule RenaissanceWeb.PurchaseControllerTest do
  use RenaissanceWeb.ConnCase
  alias Renaissance.{Auctions, Users}
  alias Plug.Test

  describe "index/2 when the user won an auction" do
    setup _context do
      {:ok, seller} = Users.insert(%{email: "seller@mail.com", password: "password"})
      {:ok, bidder} = Users.insert(%{email: "bidder@mail.com", password: "password"})

      duration_one_sec = %Timex.Duration{megaseconds: 0, seconds: 1, microseconds: 0}
      end_time_now = Timex.add(DateTime.utc_now(), duration_one_sec)

      duration_twenty_four_hours = %Timex.Duration{megaseconds: 0, seconds: 86400, microseconds: 0}
      end_time_future = Timex.add(DateTime.utc_now(), duration_twenty_four_hours)

      params_now = %{
        "title" => "Test Title",
        "description" => "Test description.",
        "end_auction_at" => end_time_now,
        "starting_amount" => "4.00",
        "seller_id" => seller.id
      }

      params_future =
        params_now
        |> Map.put("title", "Test Title Two")
        |> Map.put("description", "Test description two.")
        |> Map.put("end_auction_at", end_time_future)
        |> Map.put("starting_amount", "6.00")

      {:ok, auction_past} =
        Auctions.insert(params_now)
      {:ok, auction_future} =
        Auctions.insert(params_future)

      bid_params = %{"bidder_id" => bidder.id, "auction_id" => auction_past.id, "amount" => "8.00"}

      [bidder: bidder, seller: seller, bid_params: bid_params, past: auction_past, future: auction_future]
    end

    def place_bid(bid_params, amount) do
      bid_params |> Map.replace!("amount", amount.string) |> Bids.insert()
    end

    test "GET /purchases redirects to login when not logged in" do
      conn = get(build_conn(), "/purchases")
      assert redirected_to(conn, 302) == "/login"
    end

    test "GET /purchases displays all purchases when signed in", %{bidder: bidder, bid_params: bid_params, past: auction_past} do
      conn =
        build_conn()
        |> Test.init_test_session(current_user_id: bidder.id)
        |> post("/bids", bid_params)

      :timer.sleep(1000)

      conn = get(conn, "/purchases")

      assert html_response(conn, 200) =~ auction_past.title
      assert html_response(conn, 200) =~ auction_past.description
    end
  end
end
