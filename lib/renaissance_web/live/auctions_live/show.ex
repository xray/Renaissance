defmodule RenaissanceWeb.AuctionsLive.Show do
  @moduledoc """
  Real-time countdown to end of auction display.

  ## Attribution

    * https://www.theguild.nl/real-world-phoenix-of-groter-dan-a-liveview-dashboard
    * https://github.com/chrismccord/phoenix_live_view_example

  """

  use Phoenix.LiveView
  use Phoenix.HTML

  alias Phoenix.LiveView.Socket
  alias Timex

  def render(assigns) do
    ~L"""
    <div class="countdown">
      <%= if @time_remaining == 0 do %>
        Auction is closed.
      <% else %>
        Auction ends in<br><%= @time_remaining %>
      <% end %>
    </div>
    """
  end

  def mount(%{auction: auction}, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    {:ok, fetch(assign(socket, auction: auction))}
  end

  defp fetch(%Socket{assigns: %{auction: auction}} = socket) do
    assign(socket, time_remaining: time_remaining(auction.end_auction_at))
  end

  def handle_info(:tick, socket) do
    {:noreply, fetch(socket)}
  end

  def time_remaining(end_time) do
    if Timex.before?(Timex.now(), end_time) do
      Timex.Interval.new(from: Timex.now(), until: end_time)
      |> Timex.Interval.duration(:seconds)
      |> Timex.Duration.from_seconds()
      |> Timex.Format.Duration.Formatter.format(:humanized)
    else
      0
    end
  end
end
