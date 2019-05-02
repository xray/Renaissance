defmodule Renaissance.Helpers.Constraint do
  import Ecto.Changeset
  alias Renaissance.Helpers.Adapt
  alias Renaissance.{Auctions, Bids}

  def amount_constraint(changeset, name) do
    auction_id = get_change(changeset, :auction_id, 0)

    current_value =
      auction_id
      |> Bids.get_highest_bid()
      |> current_value()

    starting_value =
      auction_id
      |> Auctions.get_starting_price()
      |> starting_value()

    gt_number = Enum.max([current_value, starting_value])
    value = get_change(changeset, name, 0) |> Adapt.money_value()

    if value > gt_number do
      changeset
    else
      message = ~s(must be greater than #{Money.new(gt_number)})
      add_error(changeset, name, message)
    end
  end

  defp starting_value(nil), do: 0
  defp starting_value(price), do: price |> Adapt.money_value()

  defp current_value(nil), do: 0
  defp current_value(current), do: current.amount |> Adapt.money_value()
end
