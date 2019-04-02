defmodule RenaissanceWeb.PageController do
  use RenaissanceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
