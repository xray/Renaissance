defmodule RenaissanceWeb.Helpers.Auth do

  def signed_in?(conn) do
    user_email = Plug.Conn.get_session(conn, :current_user)

    user_email != nil
  end
end
