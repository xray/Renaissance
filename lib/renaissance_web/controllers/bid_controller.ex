defmodule RenaissanceWeb.BidController do
  use RenaissanceWeb, :controller

  alias Renaissance.{Bids}
  alias RenaissanceWeb.Helpers.Auth

  def create(conn, params) do
    bidder = Auth.current_user(conn)
    auction_id = String.to_integer(params["auction_id"])

    response =
      params
      |> Map.put("auction_id", auction_id)
      |> Map.put("bidder_id", bidder.id)
      |> Bids.insert()

    with {:ok, _} <- response do
      conn
      |> put_flash(:info, "Bid Placed!")
      |> redirect(to: Routes.auction_path(conn, :show, auction_id))
    else
      {:error, changeset} ->
        {_, {message, _}} = Enum.at(changeset.errors, 0)
        conn
        |> put_flash(:error, message)
        |> redirect(to: Routes.auction_path(conn, :show, auction_id))
    end
  end
end
