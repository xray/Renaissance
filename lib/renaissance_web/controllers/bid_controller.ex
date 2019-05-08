defmodule RenaissanceWeb.BidController do
  use RenaissanceWeb, :controller

  alias Renaissance.{Auctions, Bids, Helpers}
  alias RenaissanceWeb.Helpers.Auth

  def create(conn, params) do
    bidder = Auth.current_user(conn)
    auction_id = String.to_integer(params["auction_id"])

    response =
      params
      |> Map.put("auction_id", auction_id)
      |> Map.put("bidder_id", bidder.id)
      |> Bids.insert()

    with {:ok, bid} <- response do
      conn
      |> put_flash(:info, "Bid Placed!")
      |> redirect(to: Routes.auction_path(conn, :show, auction_id))
    else
      {:error, changeset} ->
        current_price =
          Bids.get_highest_bid_amount(auction_id) ||
            Auctions.get!(auction_id).price
            |> Helpers.Money.to_float()

        conn
        |> render("show.html", %{
          auction: Auctions.get!(auction_id),
          highest_bid: current_price,
          user: bidder,
          changeset: changeset
        })
    end
  end
end
