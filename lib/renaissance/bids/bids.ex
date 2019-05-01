defmodule Renaissance.Bids do
  import Ecto.Query
  alias Renaissance.{Repo, Bid}
  alias Renaissance.Helpers.Adapt

  def place_bid(params) do
    params = Adapt.format_amount(params, "amount")

    Repo.insert(Bid.changeset(%Bid{}, params))
  end

  def get(id) do
    Bid
    |> preload(:bidder)
    |> preload(:auction)
    |> Repo.get!(id)
  end
end
