defmodule RenaissanceWeb.LoginController do
  use RenaissanceWeb, :controller
  alias Renaissance.{User, Users}
  alias RenaissanceWeb.Helpers.{Auth}

  def login(conn, _params) do
    changeset = User.changeset(%User{})

    if Auth.signed_in?(conn) do
      conn
      |> put_flash(:error, "You're already logged in...")
      |> redirect(to: Routes.page_path(conn, :index))
    else
      render(conn, "login.html", changeset: changeset)
    end
  end

  def verify(conn, params) do
    case Users.verify_login(params["user"]["email"], params["user"]["password"]) do
      {:ok, _user} ->
        conn
        |> put_session(:current_user, params["user"]["email"])
        |> put_flash(:info, "You have successfully logged in!")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> render("login.html", changeset: User.changeset(%User{}))
    end
  end
end
