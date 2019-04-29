defmodule RenaissanceWeb.AuctionView do
  use RenaissanceWeb, :view

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
end
