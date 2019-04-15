defmodule RenaissanceWeb.PageControllerTest do
  use RenaissanceWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert redirected_to(conn, 302) == "/login"
  end

  test "not redirected when logged in" do
    post(build_conn(), "/register", %{"user" => %{email: "mail@mail.com", password: "password"}})

    post_login =
      post(build_conn(), "/login", %{"user" => %{email: "mail@mail.com", password: "password"}})

    conn = get(post_login, "/")

    assert html_response(conn, 200) =~ "Renaissance"
  end
end
