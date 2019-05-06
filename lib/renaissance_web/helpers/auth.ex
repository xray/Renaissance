defmodule RenaissanceWeb.Helpers.Auth do
  alias Renaissance.Users

  def signed_in?(conn) do
    current_user_id = Plug.Conn.get_session(conn, :current_user_id)

    current_user_id != nil
  end

  def current_user(conn) do
    Plug.Conn.get_session(conn, :current_user_id)
    |> return_user()
  end

  defp return_user(nil) do
    nil
  end

  defp return_user(id) do
    Users.get(id)
  end
end
