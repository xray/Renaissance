defmodule RenaissanceWeb.AuctionControllerTest do
  use RenaissanceWeb.ConnCase

  @user %{email: "mail@mail.com", password: "password"}

  test "redirects to login when not logged in" do
    conn = get(build_conn(), "/auctions/new")
    assert redirected_to(conn, 302) == "/login"
  end

  defp login do
    build_conn()
    |> post("/register", %{"user" => @user})
    |> post("/login", %{"user" => @user})
  end

  test "not redirected when logged in" do
    conn = login() |> get("/auctions/new")

    assert html_response(conn, 200) =~ "Create an Auction"
  end

  test "POST /auctions/new with valid params" do
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

  test "POST /auctions/new fails with blank title" do
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

  test "POST /auctions/new fails with blank description" do
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

  test "POST /auctions/new fails when date is in the past" do
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

  test "POST /auctions/new fails when price is 0 dollars" do
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
end