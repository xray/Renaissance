defmodule Renaissance.Auctions do
  import Ecto.Query
  alias Renaissance.{Auction, Repo, User, Users}

  def create_auction(email, params) do
    auction =
      params["auction"]
      |> add_user_id(email)
      |> format_end_date()
      |> format_price()

    Repo.insert(Auction.changeset(%Auction{}, auction))
  end

  def get_by_title(title) do
    Repo.get_by(Auction, title: title)
  end

  def get_all_auctions() do
    query =
      from a in Auction,
        join: u in User,
        on: u.id == a.user_id,
        select: {a.title, a.description, a.price, a.end_date, u.email}

    for {title, description, price, end_date, seller} <- Repo.all(query),
        do: %{
          title: title,
          description: description,
          price: Money.to_string(price),
          end_date: DateTime.to_string(end_date),
          seller: seller
        }
  end

  defp format_end_date(params) do
    datetime =
      "#{params["end_date_day"]}T#{params["end_date_time"]}:00-05:00"
      |> DateTime.from_iso8601()
      |> elem(1)

    params
    |> Map.delete("end_date_day")
    |> Map.delete("end_date_time")
    |> Map.put("end_date", datetime)
  end

  defp format_price(params) do
    price =
      params["price"]
      |> String.replace(".", "")
      |> Integer.parse()
      |> elem(0)
      |> Money.new()

    params
    |> Map.replace!("price", price)
  end

  defp add_user_id(params, email) do
    user_id_value = Users.get_by_email(email).id

    params
    |> Map.put("user_id", user_id_value)
  end
end
