defmodule RenaissanceWeb.LoginControllerTest do
  use RenaissanceWeb.ConnCase

  @user_params %{email: "mail@mail.com", password: "password"}

  test "GET /login" do
    conn = get(build_conn(), "/login")

    assert html_response(conn, 200) =~ "Login"
  end

  test "POST /login with correct email and password" do
    conn =
      build_conn()
      |> post("/register", %{"user" => @user_params})
      |> post("/login", %{"user" => @user_params})

    assert get_flash(conn, :info) == "You have successfully logged in!"
  end

  test "POST /login with account that doesn't exist" do
    conn =
      post(build_conn(), "/login", %{
        "user" => %{email: "notanaccount@test.com", password: "Password123!"}
      })

    assert get_flash(conn, :error) == "invalid user-identifier"
  end

  test "POST /login with account that exists but wrong password" do
    conn =
      build_conn()
      |> post("/register", %{"user" => @user_params})
      |> post("/login", %{"user" => %{email: "mail@mail.com", password: "Password123!"}})

    assert get_flash(conn, :error) == "invalid password"
  end

  test "GET /login while logged in" do
    conn =
      build_conn()
      |> post("/register", %{"user" => @user_params})
      |> post("/login", %{"user" => @user_params})
      |> get("/login")

    assert get_flash(conn, :error) == "You're already logged in..."
    assert redirected_to(conn, 302) == "/"
  end
end
