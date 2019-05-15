defmodule RenaissanceWeb.AuctionView do
  use RenaissanceWeb, :view
  alias Renaissance.Helpers

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

  def float_amount(amount), do: Helpers.Money.to_float(amount)
end
