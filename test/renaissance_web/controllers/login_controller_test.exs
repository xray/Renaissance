defmodule RenaissanceWeb.LoginControllerTest do
  use RenaissanceWeb.ConnCase

  test "GET /login" do
    conn = get(build_conn(), "/login")

    assert html_response(conn, 200) =~ "Login"
  end

  test "POST /login with correct email and password" do
    post(build_conn(), "/register", %{"user" => %{email: "mail@mail.com", password: "password"}})

    conn =
      post(build_conn(), "/login", %{"user" => %{email: "mail@mail.com", password: "password"}})

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
    post(build_conn(), "/register", %{"user" => %{email: "mail@mail.com", password: "password"}})

    conn =
      post(build_conn(), "/login", %{
        "user" => %{email: "mail@mail.com", password: "Password123!"}
      })

    assert get_flash(conn, :error) == "invalid password"
  end

  test "GET /login while logged in" do
    post(build_conn(), "/register", %{"user" => %{email: "mail@mail.com", password: "password"}})

    post_login =
      post(build_conn(), "/login", %{"user" => %{email: "mail@mail.com", password: "password"}})

    conn = get(post_login, "/login")

    assert get_flash(conn, :error) == "You're already logged in..."
    assert redirected_to(conn, 302) == "/"
  end
end
