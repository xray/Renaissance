defmodule Renaissance.Auctions do
  import Ecto.{Query, Changeset}
  alias Renaissance.{Repo, Auction}

  def create_auction(user_id, params) do
    details =
      if Map.has_key?(params, "auction") do
        params["auction"]
      else
        params
      end

    details =
      details
      |> format_price()
      |> Map.put("seller_id", user_id)

    Repo.insert(Auction.changeset(%Auction{}, details))
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

  def get(id) do
    Auction
    |> preload(:seller)
    |> Repo.get!(id)
  end

  def get_all() do
    Auction
    |> preload(:seller)
    |> Repo.all()
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
      extract_amount(params["price"])
      |> String.replace(".", "")
      |> String.to_integer()
      |> Money.new()

    Map.replace!(params, "price", amount)
  end
end
