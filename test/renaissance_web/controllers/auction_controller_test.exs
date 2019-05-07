defmodule RenaissanceWeb.AuctionControllerTest do
  use RenaissanceWeb.ConnCase
  alias Renaissance.{Auction, Repo, Users}
  alias Plug.Test

  test "GET /auctions redirects to login when not logged in" do
    conn = get(build_conn(), "/auctions")
    assert redirected_to(conn, 302) == "/login"
  end

  test "GET /auctions redirects to /login when not signed in" do
    conn = get(build_conn(), "/auctions")
    assert redirected_to(conn, 302) == "/login"
  end

  @valid_end %{
    day: 15,
    hour: 14,
    minute: 3,
    month: 4,
    year: 3019
  }

  @auction_one_params %{
    title: "Test Title",
    description: "Test description.",
    end_auction_at: @valid_end,
    price: "10.00"
  }

  @auction_two_params %{
    title: "Test Two Title",
    description: "Test two description.",
    end_auction_at: %{@valid_end | day: @valid_end.day + 1},
    price: "15.00"
  }

  describe "create auction" do
    setup %{conn: conn} do
      user_params = %{email: "mail@mail.com", password: "password"}
      {:ok, user} = Users.register_user(user_params)
      {:ok, conn: Test.init_test_session(conn, current_user_id: user.id, current_user: user)}
    end

    test "GET /auctions/new is accessible when logged in", %{conn: conn} do
      conn = get(conn, "/auctions/new")
      assert html_response(conn, 200) =~ "Create an Auction"
    end

    test "POST /auctions with valid params creates an auction", %{conn: conn} do
      conn = post(conn, "/auctions", @auction_one_params)
      assert get_flash(conn, :info) == "Auction Created!"
    end

    test "POST /auctions rejects auction when end date is in the past", %{conn: conn} do
      invalid_datetime = %{@valid_end | year: "1999"}
      invalid_params = %{@auction_one_params | end_auction_at: invalid_datetime}
      conn = post(conn, "/auctions", invalid_params)

      assert html_response(conn, 200) =~ "in the future"
    end

    test "GET /auctions displays all auctions when signed in", %{conn: conn} do
      conn =
        conn
        |> post("/auctions", @auction_one_params)
        |> post("/auctions", @auction_two_params)
        |> get("/auctions")

      assert html_response(conn, 200) =~ @auction_one_params.title
      assert html_response(conn, 200) =~ "$" <> @auction_one_params.price
      assert html_response(conn, 200) =~ @auction_one_params.description

      assert html_response(conn, 200) =~ @auction_two_params.title
      assert html_response(conn, 200) =~ "$" <> @auction_two_params.price
      assert html_response(conn, 200) =~ @auction_two_params.description

      refute html_response(conn, 200) =~ ~s(class="countdown")
    end

    test "GET /auctions/:id returns only the specified auction", %{conn: conn} do
      conn =
        conn
        |> post("/auctions", @auction_one_params)
        |> post("/auctions", @auction_two_params)

      auction_one_id = Repo.get_by(Auction, title: @auction_one_params.title).id
      conn = get(conn, "/auctions/#{auction_one_id}")

      assert html_response(conn, 200) =~ @auction_one_params.title
      refute html_response(conn, 200) =~ @auction_two_params.title
    end

    test "GET /auctions/:id returns more auction details than index", %{conn: conn} do
      conn = conn |> post("/auctions", @auction_one_params)

      auction_one_id = Repo.get_by(Auction, title: @auction_one_params.title).id
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

    test "GET /auctions/:id when the user is the seller the description is edittable", %{
      conn: conn
    } do
      conn = conn |> post("/auctions", @auction_one_params)
      auction_one_id = Repo.get_by(Auction, title: @auction_one_params.title).id
      conn = get(conn, "/auctions/#{auction_one_id}")

      assert html_response(conn, 200) =~
               ~s(type="text" value="#{@auction_one_params.description}")
    end

    test "PUT /auction/:id/update", %{conn: conn} do
      conn = conn |> post("/auctions", @auction_one_params)
      auction_id = Repo.get_by(Auction, title: @auction_one_params.title).id
      conn = get(conn, "/auctions/#{auction_id}")

      updated_description = "Updated " <> @auction_one_params.description

      conn =
        conn
        |> put("/auctions/#{auction_id}", %{description: updated_description})

      assert get_flash(conn, :info) == "Auction Updated!"
    end
  end
end
