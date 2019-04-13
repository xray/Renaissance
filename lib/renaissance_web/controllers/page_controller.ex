defmodule RenaissanceWeb.PageController do
  use RenaissanceWeb, :controller
  alias RenaissanceWeb.Helpers.{Auth}

  def index(conn, _params) do
    case Auth.signed_in?(conn) do
      true ->
        render(conn, "index.html")
      nil ->
        redirect(conn, to: Routes.login_path(conn, :login))
    end
  end
end
