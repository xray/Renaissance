defmodule RenaissanceWeb.AuctionControllerTest do
  use RenaissanceWeb.ConnCase

  @user_params %{email: "mail@mail.com", password: "password"}

  test "GET /auctions redirects to login when not logged in" do
    conn = get(build_conn(), "/auctions")
    assert redirected_to(conn, 302) == "/login"
  end

  @valid_end_date_time %{
    "day" => "15",
    "hour" => "14",
    "minute" => "3",
    "month" => "4",
    "year" => "3019"
  }

  @auction_one %{
    title: "Test Title",
    description: "Test description.",
    end_auction_at: @valid_end_date_time,
    price: "10.00"
  }

  defp login do
    build_conn()
    |> post("/register", %{"user" => @user_params})
    |> post("/login", %{"user" => @user_params})
  end

  test "GET /auctions/new does not redirected when logged in" do
    conn = login() |> get("/auctions/new")

    assert html_response(conn, 200) =~ "Create an Auction"
  end

  test "POST /auctions with valid params creates an auction" do
    conn = login() |> post("/auctions", @auction_one)

    assert get_flash(conn, :info) == "Auction Created!"
  end

  test "POST /auctions fails to create auction when title is blank" do
    invalid_params = Map.replace!(@auction_one, :title, "")
    conn = login() |> post("/auctions", invalid_params)

    assert html_response(conn, 200) =~ "can&#39;t be blank"
  end

  test "POST /auctions fails to create auction when description is blank" do
    invalid_params = Map.replace!(@auction_one, :description, "")
    conn = login() |> post("/auctions", invalid_params)

    assert html_response(conn, 200) =~ "can&#39;t be blank"
  end

  test "POST /auctions fails to create auction when the end date is in the past" do
    invalid_datetime = Map.replace!(@valid_end_date_time, "year", "1999")
    invalid_params = Map.replace!(@auction_one, :end_auction_at, invalid_datetime)
    conn = login() |> post("/auctions", invalid_params)

    assert html_response(conn, 200) =~ "in the future"
  end

  test "POST /auctions fails to create auction when the price is 0 dollars" do
    invalid_params = Map.replace!(@auction_one, :price, "0.00")
    conn = login() |> post("/auctions", invalid_params)

    assert html_response(conn, 200) =~ "must be greater than 0"
  end

  test "GET /auctions redirects to /login when not signed in" do
    conn = get(build_conn(), "/auctions")
    assert redirected_to(conn, 302) == "/login"
  end

  test "GET /auctions displays all auctions when signed in" do
    auction_two = %{
      title: "Test Two Title",
      description: "Test two description.",
      end_auction_at: %{
        "day" => "04",
        "hour" => "1",
        "minute" => "7",
        "month" => "12",
        "year" => "2022"
      },
      price: "15.00"
    }

    conn =
      login()
      |> post("/auctions", @auction_one)
      |> post("/auctions", auction_two)
      |> get("/auctions")

    assert html_response(conn, 200) =~ @auction_one.title
    assert html_response(conn, 200) =~ "$" <> @auction_one.price
    assert html_response(conn, 200) =~ @auction_one.description

    assert html_response(conn, 200) =~ auction_two.title
    assert html_response(conn, 200) =~ "$" <> auction_two.price
    assert html_response(conn, 200) =~ auction_two.description
  end
end
