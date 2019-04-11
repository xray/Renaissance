defmodule RenaissanceWeb.RegisterController do
  use RenaissanceWeb, :controller
  alias Renaissance.{User, Users}

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "register.html", changeset: changeset)
  end

  def register(conn, params) do
    case Users.register_user(params["user"]) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "You have successfully signed up!")
        |> redirect(to: Routes.register_path(conn, :register))

      {:error, changeset} ->
        render(conn, "register.html", changeset: changeset)
    end
  end
end
