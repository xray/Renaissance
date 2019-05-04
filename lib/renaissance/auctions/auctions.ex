defmodule Renaissance.Auctions do
  import Ecto.Query
  alias Renaissance.{Auction, Repo, Bids}
  alias Renaissance.Helpers.{Adapt, Compare}

  def create_auction(user_id, params) do
    params =
      params
      |> Adapt.format_amount("price")
      |> Map.put("seller_id", user_id)

    Auction.changeset(%Auction{}, params)
    |> Repo.insert()
  end

  def exists?(id) do
    Repo.exists?(from a in Auction, where: a.id == ^id)
  end

  def get!(id) do
    Auction
    |> preload(:seller)
    |> Repo.get!(id)
  end

  def get_seller_id(id) do
    if exists?(id), do: get!(id).seller_id
  end

  def get_starting_amount(id) do
    if exists?(id), do: get!(id).price
  end

  def get_current_amount(id) do
    larger =
      Bids.get_highest_bid_amount(id)
      |> Compare.money_max(get_starting_amount(id))

    if is_nil(larger), do: Money.new(0), else: larger
  end

  def get_all() do
    Auction
    |> preload(:seller)
    |> Repo.all()
  end

  def open?(id) do
    if exists?(id), do: get!(id).end_auction_at |> Timex.after?(Timex.now())
  end
end
