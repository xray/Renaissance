defmodule Renaissance.Bids do
  import Ecto.Query
  alias Renaissance.{Repo, Auction, User, Bid}

  def get(id) do
    Bid
    |> preload(:bidder)
    |> preload(:auction)
    |> Repo.get!(id)
  end
end
