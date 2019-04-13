defmodule RenaissanceWeb.RegisterControllerTest do
  use RenaissanceWeb.ConnCase

  test "GET /register" do
    conn = get(build_conn(), "/register")
    assert html_response(conn, 200) =~ "Register"
  end

  test "POST /register with valid email and password" do
    conn =
      post(build_conn(), "/register", %{"user" => %{email: "mail@mail.com", password: "password"}})

    assert get_flash(conn, :info) == "You have successfully signed up!"
  end

  test "POST /register with no email or password" do
    conn = post(build_conn(), "/register", %{"user" => %{email: "", password: ""}})
    assert html_response(conn, 200) =~ "can&#39;t be blank"
  end

  test "GET /register while logged in" do
    post(build_conn(), "/register", %{"user" => %{email: "mail@mail.com", password: "password"}})
    post_login = post(build_conn(), "/login", %{"user" => %{email: "mail@mail.com", password: "password"}})

    conn = get(post_login, "/register")

    assert get_flash(conn, :error) == "You're already logged in..."
    assert redirected_to(conn, 302) == "/"
  end
end
