defmodule Renaissance.Auctions do
  import Ecto.{Query, Changeset}
  alias Renaissance.{Auction, Bids, Helpers, Repo}

  def insert(params) do
    params = Helpers.Money.to_money!(params, "price")
    Auction.changeset(%Auction{}, params) |> Repo.insert()
  end

  def exists?(nil), do: false

  def exists?(id) do
    Repo.exists?(from(a in Auction, where: a.id == ^id))
  end

  def update(id, params) do
    auction = get!(id)

    args = %{
      description: params["description"] || auction.description,
      title: params["title"] || auction.title
    }

    change(auction, args) |> Repo.update()
  end

  def get!(id) do
    Auction
    |> preload(:seller)
    |> Repo.get!(id)
    |> Map.put(:current_amount, get_current_amount(id))
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
    current =
      Bids.get_highest_bid_amount(id)
      |> Helpers.Money.to_money()

    get_starting_amount(id)
    |> Helpers.Money.to_money()
    |> Helpers.Money.money_max(current)
  end

  def get_all() do
    auctions =
      Auction
      |> preload(:seller)
      |> Repo.all()

    for auction <- auctions, do: Map.put(auction, :current_amount, get_current_amount(auction.id))
  end

  def open?(id) do
    case Repo.get(Auction, id) do
      nil -> false
      auction -> Timex.after?(auction.end_auction_at, Timex.now())
    end
  end
end
