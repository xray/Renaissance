defmodule RenaissanceWeb.AuctionView do
  use RenaissanceWeb, :view
  import Calendar.NaiveDateTime
  alias Timex.{Interval, Duration, Format.Duration.Formatter}

  def pretty_time(end_time) do
    Calendar.NaiveDateTime.Format.asctime(end_time)
  end

  def time_remaining(end_time) do
    if Timex.before?(Timex.now(), end_time) do
      Timex.Interval.new(from: Timex.now(), until: end_time)
      |> Interval.duration(:seconds)
      |> Duration.from_seconds()
      |> Formatter.format(:humanized)
    else
      "Auction is closed."
    end
  end
end
