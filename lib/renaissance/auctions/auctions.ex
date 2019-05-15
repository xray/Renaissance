defmodule Renaissance.Auctions do
  import Ecto.{Query, Changeset}
  alias Renaissance.{Auction, Bid, Helpers, Repo}

  def insert(params) do
    params = Helpers.Money.to_money!(params, "starting_amount")
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

  def get!(nil), do: nil

  def get!(id) do
    Auction
    |> preload(:seller)
    |> preload(highest_bid: ^Bid.highest())
    |> Repo.get!(id)
  end

  def get_all() do
    Auction
    |> preload(:seller)
    |> preload(highest_bid: ^Bid.highest())
    |> order_by(asc: :end_auction_at, asc: :inserted_at)
    |> Repo.all()
  end

  def get_won_auctions(user_id) do
    get_all_detailed()
    |> Enum.filter(fn auction -> 
      case auction.highest_bid do
        nil -> false
        _ -> auction.highest_bid.bidder_id == user_id && !open?(auction.id)
      end
    end)
  end

  def get_open_auctions() do
    get_all_detailed()
    |> Enum.filter(fn auction -> 
      open?(auction.id)
    end)
  end

  def open?(id) do
    case Repo.get(Auction, id) do
      nil -> false
      auction -> Timex.after?(auction.end_auction_at, Timex.now())
    end
  end

  def get_detailed(id) do
    auction = get!(id)
    amount = extract_current_amount(auction)
    Map.put(auction, :current_amount, amount)
  end

  def get_all_detailed do
    for auction <- get_all() do
      Map.put(auction, :current_amount, extract_current_amount(auction))
    end
  end

  defp extract_current_amount(auction) do
    case auction.highest_bid do
      nil -> auction.starting_amount
      bid -> bid.amount
    end
    |> Helpers.Money.to_money()
  end
end
