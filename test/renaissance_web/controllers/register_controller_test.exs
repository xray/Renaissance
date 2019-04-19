defmodule RenaissanceWeb.RegisterControllerTest do
  use RenaissanceWeb.ConnCase

  @valid_params %{email: "mail@mail.com", password: "password"}

  test "GET /register/new" do
    conn = get(build_conn(), "/register/new")
    assert html_response(conn, 200) =~ "Register"
  end

  test "GET /register/new redirects to index if user logged in" do
    conn =
      build_conn()
      |> post("/register", %{"user" => @valid_params})
      |> post("/login", %{"user" => @valid_params})
      |> get("/register/new")

    assert get_flash(conn, :error) == "You're already logged in..."
    assert redirected_to(conn, 302) == "/"
  end

  test "POST /register succeeds when params valid" do
    conn = post(build_conn(), "/register", %{"user" => @valid_params})

    assert get_flash(conn, :info) == "You have successfully signed up!"
  end

  test "POST /register fails when param invalid" do
    conn = post(build_conn(), "/register", %{"user" => %{email: "", password: ""}})
    assert html_response(conn, 200) =~ "can&#39;t be blank"
  end
end
