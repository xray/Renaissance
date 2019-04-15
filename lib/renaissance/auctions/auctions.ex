defmodule Renaissance.Auctions do
  alias Renaissance.{Auction, Repo, User}

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
      |> Money.new(:USD)

    params
    |> Map.replace!("price", price)
  end

  defp add_user_id(params, email) do
    user_id = Repo.get_by(User, email: email).id

    params
    |> Map.put("user_id", user_id)
  end
end
