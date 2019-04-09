defmodule RenaissanceWeb.RegisterControllerTest do
    use RenaissanceWeb.ConnCase

    test "GET /register", %{conn: conn} do
      conn = get(conn, "/register")
      assert html_response(conn, 200) =~ "Register"
    end

    test "POST /register with valid email and password", %{conn: conn} do
      conn = post(conn, "/register", %{email: "mail@mail.com", password: "password"})
      assert html_response(conn, 200) =~ "Account Created!"
    end

    test "POST /register with no email or password", %{conn: conn} do
        conn = post(conn, "/register", %{email: "", password: ""})
        assert html_response(conn, 200) =~ "An error occured..."
      end
  end
