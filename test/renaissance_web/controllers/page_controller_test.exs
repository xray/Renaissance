defmodule RenaissanceWeb.PageControllerTest do
  use RenaissanceWeb.ConnCase

  @user_params %{email: "mail@mail.com", password: "password"}

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert redirected_to(conn, 302) == "/login"
  end

  test "not redirected when logged in" do
    conn =
      build_conn()
      |> post("/register", %{"user" => @user_params})
      |> post("/login", %{"user" => @user_params})
      |> get("/")

    assert html_response(conn, 200) =~ "Renaissance"
  end
end
