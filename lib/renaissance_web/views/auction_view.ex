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

  def float_amount(amount) do
    Helpers.Money.to_float(amount)
  end

  def auction_open?(auction) do
    Auctions.open?(auction.id)
  end
end
