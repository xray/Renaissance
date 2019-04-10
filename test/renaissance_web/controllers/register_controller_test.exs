defmodule RenaissanceWeb.RegisterControllerTest do
  use RenaissanceWeb.ConnCase

  test "GET /register" do
    conn = get(build_conn(), "/register")
    assert html_response(conn, 200) =~ "Register"
  end

  test "POST /register with valid email and password" do
    conn = post(build_conn(), "/register", email: "mail@mail.com", password: "password")
    assert get_flash(conn, :info) == "You have successfully signed up!"
  end

  test "POST /register with no email or password" do
    conn = post(build_conn(), "/register", email: "", password: "")
    assert get_flash(conn, :error) == "An error occurred!"
  end
end
