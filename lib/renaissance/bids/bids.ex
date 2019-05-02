defmodule Renaissance.Bids do
  import Ecto.Query
  alias Renaissance.{Repo, Bid}
  alias Renaissance.Helpers.Adapt

  def place_bid(params) do
    params = Adapt.format_amount(params, "amount")

    Repo.insert(Bid.changeset(%Bid{}, params))
  end

  def get_highest_bid(auction_id) do
    query = "SELECT bidder_id, amount, created_at
             FROM bids
             WHERE amount = (
                SELECT MAX(amount)
                FROM bids
                WHERE #{auction_id} = auction_id
             );"

    result = Ecto.Adapters.SQL.query!(Repo, query, [])

    types = %{
      bidder_id: :integer,
      amount: Money.Ecto.Amount.Type,
      created_at: :utc_datetime
    }

    Enum.map(result.rows, &Repo.load(types, {result.columns, &1})) |> Enum.at(0)
  end

  def get_highest_bid_amount(auction_id) do
    query =
      from b in "bids",
        select: b.amount,
        where: b.auction_id == ^auction_id

    Repo.aggregate(query, :max, :amount)
  end

  def get(id) do
    Bid
    |> preload(:bidder)
    |> preload(:auction)
    |> Repo.get!(id)
  end
end