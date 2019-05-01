defmodule RenaissanceWeb.RegisterControllerTest do
  use RenaissanceWeb.ConnCase
  alias Renaissance.Users
  alias Plug.Test

  @valid_params %{email: "mail@mail.com", password: "password"}

  describe "new/2" do
    test "GET /register/new" do
      conn = get(build_conn(), "/register/new")
      assert html_response(conn, 200) =~ "Register"
    end

    test "GET /register/new redirects to index if user logged in" do
      {:ok, user} = Users.register_user(@valid_params)

      conn =
        build_conn()
        |> Test.init_test_session(current_user_id: user.id)
        |> get("/register/new")

      assert get_flash(conn, :error) == "You're already logged in..."
      assert redirected_to(conn, 302) == "/"
    end
  end

  describe "create/2" do
    test "POST /register succeeds when params valid" do
      conn = post(build_conn(), "/register", %{"user" => @valid_params})

      assert get_flash(conn, :info) == "You have successfully signed up!"
    end

    test "POST /register fails when param invalid" do
      conn = post(build_conn(), "/register", %{"user" => %{@valid_params | password: ""}})
      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end
  end
end
