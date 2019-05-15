defmodule RenaissanceWeb.BidController do
  use RenaissanceWeb, :controller

  alias Renaissance.Bids
  alias RenaissanceWeb.Helpers.Auth

  def create(conn, %{"amount" => amount, "auction_id" => auction_id}) do
    params = %{
      "amount" => amount,
      "auction_id" => auction_id,
      "bidder_id" => Auth.current_user(conn).id
    }

    case Bids.insert(params) do
      {:ok, _bid} ->
        conn
        |> put_flash(:info, "Bid Placed!")
        |> redirect(to: Routes.auction_path(conn, :show, auction_id))

      {:error, changeset} ->
        {_, {message, _}} = Enum.at(changeset.errors, 0)

        conn
        |> put_flash(:error, message)
        |> redirect(to: Routes.auction_path(conn, :show, auction_id))
    end
  end
end
