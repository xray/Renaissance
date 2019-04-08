defmodule RenaissanceWeb.RegisterController do
  use RenaissanceWeb, :controller

  def index(conn, _params) do
    render(conn, "register.html")
  end
end
