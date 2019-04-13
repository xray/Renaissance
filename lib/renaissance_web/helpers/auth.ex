defmodule RenaissanceWeb.Helpers.Auth do
  alias Renaissance.{User, Repo}

  def signed_in?(conn) do
    user_email = Plug.Conn.get_session(conn, :current_user)
    if user_email, do: !!Repo.get_by(User, email: user_email)
  end

end