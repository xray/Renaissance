defmodule Renaissance.Bids do
  import Ecto.Query
  import Ecto.Changeset
  alias Renaissance.{Bid, Helpers, Repo}

  def insert(params) do
    params = Helpers.Money.to_money!(params, "amount")

    lock_update(params)
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

  defp lock_update(params) do
    Repo.transaction(fn ->
      _ =
        Bid
        |> select(1)
        |> limit(1)
        |> lock("FOR UPDATE")
        |> Repo.one()

      Bid.changeset(%Bid{}, params)
      |> Repo.insert()
    end)
    |> case do
      {:ok, result} -> result
      {:error, :rollback} -> {
        :error, 
        Bid.changeset(%Bid{}, params)
        |> Ecto.Changeset.add_error(:auction, "An error occured, your bid was not placed.")
      }
      {:error, error} -> error
    end
  end
end
