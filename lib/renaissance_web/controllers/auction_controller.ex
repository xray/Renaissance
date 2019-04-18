defmodule RenaissanceWeb.AuctionController do
  use RenaissanceWeb, :controller
  alias Renaissance.Auctions
  alias RenaissanceWeb.Helpers.Auth

  def index(conn, _params) do
    if Auth.signed_in?(conn) do
      render(conn, "index.html", auctions: Auctions.get_all_auctions())
    else
      conn |> redirect(to: Routes.login_path(conn, :login))
    end
  end

  def new(conn, _params) do
    if Auth.signed_in?(conn) do
      render(conn, "new.html", changeset: conn)
    else
      conn |> redirect(to: Routes.login_path(conn, :login))
    end
  end

  def create(conn, params) do
    response =
      conn
      |> get_session(:current_user)
      |> Auctions.create_auction(params)

    case response do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Auction Created!")
        |> redirect(to: Routes.auction_path(conn, :index))

      {:error, changeset} ->
        render(conn, "create.html", changeset: changeset)
    end
  end
end
