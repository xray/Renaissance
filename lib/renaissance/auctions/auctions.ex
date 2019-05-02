defmodule Renaissance.Auctions do
  import Ecto.Query
  alias Renaissance.{Auction, Repo, Bids}
  alias Renaissance.Helpers.{Adapt, Compare}

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

  def get!(id) do
    Auction
    |> preload(:seller)
    |> Repo.get!(id)
  end

  def get_seller_id(id) do
    auction = Repo.get(Auction, id)
    if is_nil(auction), do: 0, else: auction.seller_id
  end

  def get_starting_amount(id) do
    auction = Repo.get(Auction, id)
    if is_nil(auction), do: 0, else: auction.price
  end

  def get_current_amount(id) do
    starting_amount = get_starting_amount(id)
    current_amount = Bids.get_highest_bid_amount(id)

    larger = Compare.money_max(starting_amount, current_amount)
    if is_nil(larger), do: Money.new(0), else: larger
  end

  def get_all() do
    Auction
    |> preload(:seller)
    |> Repo.all()
  end

  def open?(id) do
    Timex.after?(get!(id).end_auction_at, Timex.now())
  end
end
