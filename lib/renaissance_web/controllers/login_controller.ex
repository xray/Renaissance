defmodule RenaissanceWeb.LoginController do
  use RenaissanceWeb, :controller
  alias Renaissance.{User, Users}
  alias RenaissanceWeb.Helpers.{Auth}

  def login(conn, _params) do
    changeset = User.changeset(%User{})

    if Auth.signed_in?(conn) do
      conn
      |> put_flash(:error, "You're already logged in...")
      |> redirect(to: Routes.auction_path(conn, :index))
    else
      render(conn, "login.html", changeset: changeset)
    end
  end

  def verify(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case Users.verify_login(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, "You have successfully logged in!")
        |> redirect(to: Routes.auction_path(conn, :index))

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> render("login.html", changeset: User.changeset(%User{}))
    end
  end
end
