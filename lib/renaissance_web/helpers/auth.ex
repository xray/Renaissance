defmodule RenaissanceWeb.Helpers.Auth do
  def signed_in?(conn) do
    current_user_id = Plug.Conn.get_session(conn, :current_user_id)

    current_user_id != nil
  end
end
