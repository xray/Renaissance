defmodule Renaissance.Bids do
  import Ecto.{Changeset, Query}
  alias Renaissance.{Bid, Helpers, Repo}

  def insert(params) do
    params = Helpers.Money.to_money!(params, "amount")

    case lock_update(params) do
      {:ok, result} ->
        result

      {:error, :rollback} ->
        message = "An error occured, your bid was not placed."
        changeset = Bid.changeset(%Bid{}, params)
        {:error, add_error(changeset, :auction, message)}

      {:error, changeset} ->
        changeset
    end
  end

  defp lock_update(params) do
    Repo.transaction(fn ->
      from b in Bid,
        select: b,
        lock: "FOR UPDATE",
        limit: 1

      Bid.changeset(%Bid{}, params)
      |> Repo.insert()
    end)
  end

  def exists(nil), do: nil

  def exists?(id) do
    Repo.exists?(from b in Bid, where: b.id == ^id)
  end

  def get_highest_bid(nil), do: nil

  def get_highest_bid(auction_id) do
    Bid.highest()
    |> where([b], b.auction_id == ^auction_id)
    |> Repo.one()
  end

  def get!(id) do
    Bid
    |> preload(:bidder)
    |> preload(:auction)
    |> Repo.get!(id)
  end
end
