defmodule RenaissanceWeb.AuctionController do
  use RenaissanceWeb, :controller
  alias Renaissance.{Auction, Auctions}
  alias RenaissanceWeb.Helpers.{Auth}

  def new(conn, _params) do
    changeset = Auction.changeset(%Auction{})
    if Auth.signed_in?(conn) do
      render(conn, "new_auction.html", changeset: changeset)
    else
      conn
      |> redirect(to: Routes.login_path(conn, :login))
    end
  end

  def create(conn, params) do
    changeset = conn
    |> get_session(:current_user)
    |> Auctions.create_auction(params)

    case changeset do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Auction Created!")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new_auction.html", changeset: changeset)
    end
  end
end
