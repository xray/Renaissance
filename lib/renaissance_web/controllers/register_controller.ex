defmodule RenaissanceWeb.RegisterController do
  use RenaissanceWeb, :controller
  alias Renaissance.{Users}

  def new(conn, _params) do
    render(conn, "register.html", changeset: conn)
  end

  def register(conn, params) do
    case Users.register_user(params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "You have successfully signed up!")
        |> redirect(to: Routes.register_path(conn, :register))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "An error occurred!")
        |> redirect(to: Routes.register_path(conn, :new))
    end
  end
end
