defmodule RenaissanceWeb.AuctionView do
  use RenaissanceWeb, :view
  alias Renaissance.{Helpers, Auctions}

  def default_end do
    current = DateTime.utc_now()

    %{
      day: current.day,
      hour: current.hour,
      minute: current.minute,
      month: current.month,
      year: current.year
    }
  end

  def auction_open?(auction) do
    Auctions.open?(auction.id)
  end

  def display_value(auction) do
    if is_nil(auction.highest_bid) do
      auction.price
    else
      auction.highest_bid.amount
    end
  end

  def float_value(auction) do
    if is_nil(auction.highest_bid) do
      Helpers.Money.to_float(auction.price)
    else
      Helpers.Money.to_float(auction.highest_bid.amount)
    end
  end
end
