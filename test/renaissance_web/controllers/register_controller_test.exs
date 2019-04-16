defmodule RenaissanceWeb.RegisterControllerTest do
  use RenaissanceWeb.ConnCase

  @user_params %{email: "mail@mail.com", password: "password"}

  test "GET /register" do
    conn = get(build_conn(), "/register")
    assert html_response(conn, 200) =~ "Register"
  end

  test "POST /register with valid email and password" do
    conn = post(build_conn(), "/register", %{"user" => @user_params})

    assert get_flash(conn, :info) == "You have successfully signed up!"
  end

  test "POST /register with no email or password" do
    conn = post(build_conn(), "/register", %{"user" => %{email: "", password: ""}})
    assert html_response(conn, 200) =~ "can&#39;t be blank"
  end

  test "GET /register while logged in" do
    conn =
      build_conn()
      |> post("/register", %{"user" => @user_params})
      |> post("/login", %{"user" => @user_params})
      |> get("/register")

    assert get_flash(conn, :error) == "You're already logged in..."
    assert redirected_to(conn, 302) == "/"
  end
end
