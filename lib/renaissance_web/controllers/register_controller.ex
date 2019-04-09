defmodule RenaissanceWeb.RegisterController do
  use RenaissanceWeb, :controller
  alias RenaissanceWeb.{ErrorHelpers}
  alias Renaissance.{Users}

  def index(conn, _params) do
    render(conn, "register.html", token: get_csrf_token(), error: false)
  end

  def new(conn, params) do
    register_params = %{email: params["email"], password: params["password"]}

    case Users.register_user(register_params) do
      {:ok, _user} ->
        render(conn, "registered.html")
      {:error, changeset} ->
        render(conn, "register.html", token: get_csrf_token(), error: true)
    end
  end
end
