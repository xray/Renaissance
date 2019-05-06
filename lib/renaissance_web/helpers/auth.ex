defmodule RenaissanceWeb.Helpers.Auth do
  alias Renaissance.Users

  def signed_in?(conn) do
    current_user_id = Plug.Conn.get_session(conn, :current_user_id)

    current_user_id != nil
  end

  def current_user(conn) do
    case Plug.Conn.get_session(conn, :current_user_id) do
      nil ->
        nil

      id ->
        Users.get(id)
    end
  end
end
