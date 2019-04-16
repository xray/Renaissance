defmodule RenaissanceWeb.AuctionControllerTest do
  use RenaissanceWeb.ConnCase

  @user_params %{email: "mail@mail.com", password: "password"}

  test "GET /auctions/new redirects to login when not logged in" do
    conn = get(build_conn(), "/auctions/new")
    assert redirected_to(conn, 302) == "/login"
  end

  defp login do
    build_conn()
    |> post("/register", %{"user" => @user_params})
    |> post("/login", %{"user" => @user_params})
  end

  test "GET /auctions/new does not redirected when logged in" do
    conn = login() |> get("/auctions/new")

    assert html_response(conn, 200) =~ "Create an Auction"
  end

  test "POST /auctions/new with valid params creates an auction" do
    conn =
      login()
      |> post("/auctions/new", %{
        "auction" => %{
          title: "Test Title",
          description: "Test description.",
          end_date_day: "3019-04-15",
          end_date_time: "14:03",
          price: "10.00"
        }
      })

    assert get_flash(conn, :info) == "Auction Created!"
  end

  test "POST /auctions/new fails to create auction when title is blank" do
    conn =
      login()
      |> post("/auctions/new", %{
        "auction" => %{
          title: "",
          description: "Test description.",
          end_date_day: "3019-04-15",
          end_date_time: "14:03",
          price: "10.00"
        }
      })

    assert html_response(conn, 200) =~ "can&#39;t be blank"
  end

  test "POST /auctions/new fails to create auction when description is blank" do
    conn =
      login()
      |> post("/auctions/new", %{
        "auction" => %{
          title: "Test Title",
          description: "",
          end_date_day: "3019-04-15",
          end_date_time: "14:03",
          price: "10.00"
        }
      })

    assert html_response(conn, 200) =~ "can&#39;t be blank"
  end

  test "POST /auctions/new fails to create auction when the end date is in the past" do
    conn =
      login()
      |> post("/auctions/new", %{
        "auction" => %{
          title: "Test Title",
          description: "Test description.",
          end_date_day: "1776-07-04",
          end_date_time: "12:00",
          price: "10.00"
        }
      })

    assert html_response(conn, 200) =~ "End date needs to be in the future."
  end

  test "POST /auctions/new fails to create auction when the price is 0 dollars" do
    conn =
      login()
      |> post("/auctions/new", %{
        "auction" => %{
          title: "Test Title",
          description: "Test description.",
          end_date_day: "3019-04-15",
          end_date_time: "14:03",
          price: "0.00"
        }
      })

    assert html_response(conn, 200) =~ "Price needs to be greater than 0."
  end

  test "GET /auctions redirects to /login when not signed in" do
    conn = get(build_conn(), "/auctions")
    assert redirected_to(conn, 302) == "/login"
  end

  test "GET /auctions displays all auctions when signed in" do
    conn =
      build_conn()
      |> post("/register", %{"user" => %{email: "mail@mail.com", password: "password"}})
      |> post("/login", %{"user" => %{email: "mail@mail.com", password: "password"}})
      |> post("/auctions/new", %{
        "auction" => %{
          title: "Test Title",
          description: "Test description.",
          end_date_day: "3019-04-15",
          end_date_time: "14:03",
          price: "10.00"
        }
      })
      |> post("/auctions/new", %{
        "auction" => %{
          title: "Test Two Title",
          description: "Test two description.",
          end_date_day: "3019-04-15",
          end_date_time: "14:03",
          price: "15.00"
        }
      })
      |> get("/auctions")

    assert html_response(conn, 200) =~ "Test Title"
    assert html_response(conn, 200) =~ "Test description."
    assert html_response(conn, 200) =~ "$10.00"
    assert html_response(conn, 200) =~ "Test Two Title"
    assert html_response(conn, 200) =~ "Test two description."
    assert html_response(conn, 200) =~ "$15.00"
  end
end
