defmodule Renaissance.Auctions do
  import Ecto.Query
  alias Renaissance.{Repo, Users, User, Auction}

  def create_auction(email, params) do
    details =
      if Map.has_key?(params, "auction") do
        params["auction"]
      else
        params
      end

    details =
      details
      |> add_user_id(email)
      |> format_price()

    Repo.insert(Auction.changeset(%Auction{}, details))
  end

  def get_by_title(title) do
    Repo.get_by(Auction, title: title)
  end

  def get_all_auctions() do
    query =
      from a in Auction,
        join: u in User,
        on: u.id == a.user_id,
        select: {a.title, a.description, a.price, a.end_auction_at, u.email}

    for {title, description, price, end_auction_at, seller} <- Repo.all(query),
        do: %{
          title: title,
          description: description,
          price: Money.to_string(price),
          end_auction_at: DateTime.to_string(end_auction_at),
          seller: seller
        }
  end

  defp format_price(params) do
    amount =
      params["price"]
      |> String.replace(".", "")
      |> String.to_integer()
      |> Money.new()

    params |> Map.replace!("price", amount)
  end

  defp add_user_id(params, email) do
    params |> Map.put("user_id", Users.get_by_email(email).id)
  end
end
