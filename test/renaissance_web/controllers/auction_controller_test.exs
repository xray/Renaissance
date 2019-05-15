defmodule RenaissanceWeb.AuctionControllerTest do
  use RenaissanceWeb.ConnCase
  alias Renaissance.{Auction, Auctions, Repo, Users}
  alias Plug.Test

  @valid_user_params %{email: "mail@mail.com", password: "password"}

  @valid_end %{day: 15, hour: 14, minute: 3, month: 4, year: 3019}

  @auction_one_params %{
    auction: %{
      title: "Test Title",
      description: "Test description.",
      end_auction_at: @valid_end,
      starting_amount: "10.00"
    }
  }

  @auction_two_params %{
    auction: %{
      title: "Test Two Title",
      description: "Test two description.",
      end_auction_at: %{@valid_end | day: @valid_end.day + 1},
      starting_amount: "15.00"
    }
  }

  describe "index/2" do
    test "GET /auctions redirects to login when not logged in" do
      conn = get(build_conn(), "/auctions")
      assert redirected_to(conn, 302) == "/login"
    end

    test "GET /auctions displays all auctions when signed in" do
      {:ok, user} = Users.insert(@valid_user_params)

      conn =
        build_conn()
        |> Test.init_test_session(current_user_id: user.id)
        |> post("/auctions", @auction_one_params)
        |> post("/auctions", @auction_two_params)
        |> get("/auctions")

      assert html_response(conn, 200) =~ @auction_one_params.auction.title
      assert html_response(conn, 200) =~ "$" <> @auction_one_params.auction.starting_amount
      assert html_response(conn, 200) =~ @auction_one_params.auction.description

      assert html_response(conn, 200) =~ @auction_two_params.auction.title
      assert html_response(conn, 200) =~ "$" <> @auction_two_params.auction.starting_amount
      assert html_response(conn, 200) =~ @auction_two_params.auction.description

      refute html_response(conn, 200) =~ ~s(class="countdown")
    end
  end

  describe "new/2" do
    test "GET /auctions/new redirects to login when not logged in" do
      conn = get(build_conn(), "/auctions/new")
      assert redirected_to(conn, 302) == "/login"
    end

    test "GET /auctions/new is accessible when logged in" do
      {:ok, user} = Users.insert(@valid_user_params)

      conn =
        build_conn()
        |> Test.init_test_session(current_user_id: user.id)
        |> get("/auctions/new")

      assert html_response(conn, 200) =~ "Create an Auction"
    end
  end

  describe "create/2" do
    setup %{conn: conn} do
      {:ok, user} = Users.insert(@valid_user_params)
      {:ok, conn: Test.init_test_session(conn, current_user_id: user.id, current_user: user)}
    end

    test "POST /auctions with valid params creates an auction", %{conn: conn} do
      conn = post(conn, "/auctions", @auction_one_params)
      assert get_flash(conn, :info) == "Auction Created!"
    end

    test "POST /auctions rejects auction when end date is in the past", %{conn: conn} do
      invalid_datetime = %{@valid_end | year: "1999"}
      invalid_params = %{@auction_one_params.auction | end_auction_at: invalid_datetime}
      conn = post(conn, "/auctions", %{auction: invalid_params})

      assert html_response(conn, 200) =~ "in the future"
    end
  end

  describe "show/2" do
    setup %{conn: conn} do
      user_params = %{email: "mail@mail.com", password: "password"}
      {:ok, user} = Users.insert(user_params)
      {:ok, conn: Test.init_test_session(conn, current_user_id: user.id)}
    end

    test "GET /auctions/:id returns only the specified auction", %{conn: conn} do
      conn =
        conn
        |> post("/auctions", @auction_one_params)
        |> post("/auctions", @auction_two_params)

      auction_one_id = Repo.get_by(Auction, title: @auction_one_params.auction.title).id
      conn = get(conn, "/auctions/#{auction_one_id}")

      assert html_response(conn, 200) =~ @auction_one_params.auction.title
      refute html_response(conn, 200) =~ @auction_two_params.auction.title
    end

    test "GET /auctions/:id returns more auction details than index", %{conn: conn} do
      conn = conn |> post("/auctions", @auction_one_params)

      auction_one_id = Repo.get_by(Auction, title: @auction_one_params.auction.title).id
      conn = get(conn, "/auctions/#{auction_one_id}")

      assert html_response(conn, 200) =~ ~s(class="countdown")
      assert html_response(conn, 200) =~ "Auction ends in"
      assert html_response(conn, 200) =~ " years"
    end

    test "GET /auctions/:id fails when invalid id", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, "/auctions/0")
      end
    end

    test "GET /auctions/:id description is editable when viewed by the seller", %{conn: conn} do
      conn = post(conn, "/auctions", @auction_one_params)
      auction_one_id = Repo.get_by(Auction, title: @auction_one_params.auction.title).id

      conn = get(conn, "/auctions/#{auction_one_id}")

      assert html_response(conn, 200) =~
               ~s(type="text" value="#{@auction_one_params.auction.description}")
    end

    test "PUT /auction/:id for description", %{conn: conn} do
      conn = conn |> post("/auctions", @auction_one_params)
      auction_id = Repo.get_by(Auction, title: @auction_one_params.auction.title).id
      conn = get(conn, "/auctions/#{auction_id}")

      updated_description = "Updated " <> @auction_one_params.auction.description

      conn =
        conn
        |> put("/auctions/#{auction_id}", %{description: updated_description})

      assert get_flash(conn, :info) == "Auction Updated!"
    end

    test "GET /auctions/:id when the user is the seller the title is editable", %{
      conn: conn
    } do
      conn = conn |> post("/auctions", @auction_one_params)
      auction_one_id = Repo.get_by(Auction, title: @auction_one_params.auction.title).id
      conn = get(conn, "/auctions/#{auction_one_id}")

      assert html_response(conn, 200) =~
               ~s(type="text" value="#{@auction_one_params.auction.title}")
    end

    test "PUT /auction/:id for title", %{conn: conn} do
      conn = conn |> post("/auctions", @auction_one_params)
      auction_id = Repo.get_by(Auction, title: @auction_one_params.auction.title).id
      conn = get(conn, "/auctions/#{auction_id}")

      updated_title = "Updated " <> @auction_one_params.auction.title

      conn = put(conn, "/auctions/#{auction_id}", %{title: updated_title})

      assert get_flash(conn, :info) == "Auction Updated!"
    end
  end

  describe "show/2 when the auction does not belong to the user" do
    setup %{conn: conn} do
      {:ok, seller} = Users.insert(%{email: "seller@seller.com", password: "password"})
      {:ok, bidder} = Users.insert(%{email: "bidder@bidder.com", password: "password"})

      Auctions.insert(%{
        "title" => "Test Title",
        "description" => "Test description.",
        "end_auction_at" => @valid_end,
        "starting_amount" => "10.00",
        "seller_id" => seller.id
      })

      {:ok, conn: Test.init_test_session(conn, current_user_id: bidder.id)}
    end

    test "GET /auction/:id a form for placing a bid is present", %{conn: conn} do
      auction_id = Repo.get_by(Auction, title: @auction_one_params.auction.title).id

      conn = get(conn, "/auctions/#{auction_id}")

      assert html_response(conn, 200) =~ ~s(<button type="submit">Submit Bid</button>)
    end
  end

  describe "show/2 when the auction has ended and does not belong to the user" do
    @tag :sleeps
    setup %{conn: conn} do
      {:ok, seller} = Users.insert(%{email: "seller@seller.com", password: "password"})
      {:ok, bidder} = Users.insert(%{email: "bidder@bidder.com", password: "password"})

      duration = %Timex.Duration{megaseconds: 0, seconds: 1, microseconds: 0}
      end_time = Timex.add(DateTime.utc_now(), duration)

      Auctions.insert(%{
        "title" => "Test Title",
        "description" => "Test description.",
        "end_auction_at" => end_time,
        "starting_amount" => "10.00",
        "seller_id" => seller.id
      })

      :timer.sleep(1000)

      {:ok, conn: Test.init_test_session(conn, current_user_id: bidder.id)}
    end

    test "GET /auction/:id a form for placing a bid is not present", %{conn: conn} do
      auction_id = Repo.get_by(Auction, title: @auction_one_params.auction.title).id

      conn = get(conn, "/auctions/#{auction_id}")

      refute html_response(conn, 200) =~ ~s(<button type="submit">Submit Bid</button>)
    end
  end
end
