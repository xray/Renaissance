defmodule Renaissance.Bids do
  import Ecto.Query
  alias Renaissance.{Repo, Auction, User, Bid}

  def get(id) do
    Bid
    |> preload(:bidder)
    |> preload(:auction)
    |> Repo.get!(id)
  end

  defp extract_amount(amount) do
    if is_nil(amount) do
      "000"
    else
      amount
    end
  end

  defp format_price(params) do
    amount =
      extract_amount(params["amount"])
      |> String.replace(".", "")
      |> String.to_integer()
      |> Money.new()

    Map.replace!(params, "amount", amount)
  end
end
