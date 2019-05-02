defmodule Renaissance.Auctions do
  import Ecto.Query
  alias Renaissance.{Repo, Auction}
  alias Renaissance.Helpers.Adapt

  def create_auction(user_id, params) do
    details =
      if Map.has_key?(params, "auction") do
        params["auction"]
      else
        params
      end

    details =
      details
      |> Adapt.format_amount("price")
      |> Map.put("seller_id", user_id)

    Repo.insert(Auction.changeset(%Auction{}, details))
  end

  def get(id) do
    Auction
    |> preload(:seller)
    |> Repo.get!(id)
  end

  def get_starting_price(id) do
    auction = Repo.get(Auction, id)
    if is_nil(auction), do: 0, else: auction.price
  end

  def get_all() do
    Auction
    |> preload(:seller)
    |> Repo.all()
  end

  def open?(id) do
    Timex.after?(get(id).end_auction_at, Timex.now())
  end
end
