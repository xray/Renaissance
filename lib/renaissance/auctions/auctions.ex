defmodule Renaissance.Auctions do
  import Ecto.Query
  alias Renaissance.{Auction, Repo, Bids}
  alias Renaissance.Helpers

  def insert(user_id, params) do
    params =
      params
      |> Helpers.Money.to_money!("price")
      |> Map.put("seller_id", user_id)

    Auction.changeset(%Auction{}, params)
    |> Repo.insert()
  end

  def exists?(nil), do: false

  def exists?(id) do
    Repo.exists?(from(a in Auction, where: a.id == ^id))
  end

  def update_auction(auction_id, params) do
    auction =
      Auction
      |> Repo.get!(auction_id)

    change(auction, %{
      description: params["description"] || auction.description,
      title: params["title"] || auction.title
    })
    |> Repo.update()
  end

  def get!(id) do
    Auction
    |> preload(:seller)
    |> Repo.get!(id)
  end

  def get_seller_id(nil), do: nil

  def get_seller_id(id) do
    case Repo.get(Auction, id) do
      nil -> nil
      auction -> auction.seller_id
    end
  end

  def get_starting_amount(nil), do: nil

  def get_starting_amount(id) do
    case Repo.get(Auction, id) do
      nil -> nil
      auction -> auction.price
    end
  end

  def get_current_amount(nil), do: nil

  def get_current_amount(id) do
    starting = get_starting_amount(id) |> Helpers.Money.to_money()
    current = Bids.get_highest_bid_amount(id) |> Helpers.Money.to_money()

    Helpers.Money.money_max(starting, current)
  end

  def get_all() do
    Auction
    |> preload(:seller)
    |> Repo.all()
  end

  def open?(id) do
    case Repo.get(Auction, id) do
      nil -> false
      auction -> Timex.after?(auction.end_auction_at, Timex.now())
    end
  end
end
