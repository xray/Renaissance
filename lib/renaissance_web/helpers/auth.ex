defmodule RenaissanceWeb.Helpers.Auth do

  def signed_in?(conn) do
    user_email = Plug.Conn.get_session(conn, :current_user)

    if user_email == nil do
      false
    else
      true
    end
  end
end
