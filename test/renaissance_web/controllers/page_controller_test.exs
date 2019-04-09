defmodule RenaissanceWeb.PageControllerTest do
  use RenaissanceWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Hello World!"
  end
end
