defmodule Renaissance.Bids do
  import Ecto.Query
  alias Renaissance.{Bid, Helpers, Repo}

  def insert(params) do
    params = Helpers.Money.to_money!(params, "amount")
    Bid.changeset(%Bid{}, params) |> Repo.insert()
  end

  def exists(nil), do: nil

  def exists?(id) do
    Repo.exists?(from b in Bid, where: b.id == ^id)
  end

  def get_highest_bid_amount(nil), do: nil

  def get_highest_bid_amount(auction_id) do
    query =
      from b in "bids",
        select: type(b.amount, Money.Ecto.Type),
        where: b.auction_id == ^auction_id

    Repo.aggregate(query, :max, :amount)
  end

  def get_highest_bid(nil), do: nil

  def get_highest_bid(auction_id) do
    highest_amount = get_highest_bid_amount(auction_id)
    # and b.created_at <= ^end_action_at
    query =
      from b in Bid,
        where: b.auction_id == ^auction_id and b.amount == type(^highest_amount, b.amount),
        order_by: [asc: b.created_at],
        select: %{
          id: b.id,
          amount: b.amount,
          created_at: b.created_at,
          bidder_id: b.bidder_id,
          auction_id: b.auction_id
        }

    Repo.one(query)
  end

  def get!(id) do
    Bid
    |> preload(:bidder)
    |> preload(:auction)
    |> Repo.get!(id)
  end
end
