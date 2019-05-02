defmodule Renaissance.Helpers.Constraint do
  import Ecto.Changeset
  alias Renaissance.Helpers.Adapt
  alias Renaissance.Auctions

  defp current_value(nil), do: 0
  defp current_value(id), do: Auctions.get_current_amount(id) |> Adapt.money_value()

  def amount_constraint(changeset, name) do
    proposed_value = get_change(changeset, name, 0) |> Adapt.money_value()

    auction_id = get_change(changeset, :auction_id)
    current_value = current_value(auction_id)

    if proposed_value > current_value do
      changeset
    else
      message = ~s(must be greater than #{Money.new(current_value)})
      add_error(changeset, name, message)
    end
  end

  def bidder_constraint(changeset, name) do
    auction_id = get_change(changeset, :auction_id)
    bidder_constraint_helper(changeset, name, auction_id)
  end

  defp bidder_constraint_helper(changeset, _, nil), do: changeset

  defp bidder_constraint_helper(changeset, name, auction_id) do
    bidder_id = get_change(changeset, name)
    seller_id = Auctions.get_seller_id(auction_id)

    if bidder_id != seller_id do
      changeset
    else
      message = ~s(can't bid on auction item that you're selling)
      add_error(changeset, name, message)
    end
  end
end
