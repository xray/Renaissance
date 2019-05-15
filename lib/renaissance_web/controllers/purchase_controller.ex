defmodule RenaissanceWeb.PurchaseController do
  use RenaissanceWeb, :controller

  alias RenaissanceWeb.Helpers.Auth
  alias Renaissance.Auctions

  def index(conn, _params) do
    user = Auth.current_user(conn)
    if Auth.signed_in?(conn) do
      won_auctions = Auctions.get_won_auctions(user.id)
      if Enum.count(won_auctions) > 0 do
        render(conn, "purchases.html", auctions: won_auctions)
      else
        conn
        |> put_flash(:error, "You have not made any purchases yet.")
        |> redirect(to: Routes.auction_path(conn, :index))
      end
    else
      redirect(conn, to: Routes.login_path(conn, :login))
    end
  end
end
