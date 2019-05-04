defmodule Renaissance.Helpers.Constraint do
  import Ecto.Changeset
  alias Renaissance.Helpers.Adapt
  alias Renaissance.Auctions

  def amount_constraint(changeset, field) do
    auction_id = get_change(changeset, :auction_id, 0)

    proposed = get_change(changeset, field, 0) |> Adapt.money_value()
    current = Auctions.get_current_amount(auction_id) |> Adapt.money_value()

    if proposed > current do
      changeset
    else
      message = ~s(must be greater than #{Money.new(current)})
      add_error(changeset, field, message)
    end
  end

  def bidder_constraint(changeset, field) do
    bidder_id = get_change(changeset, field)
    auction_id = get_change(changeset, :auction_id, 0)
    seller_id = Auctions.get_seller_id(auction_id)

    if is_nil(seller_id) or bidder_id != seller_id do
      changeset
    else
      message = ~s(can't bid on auction item that you're selling)
      add_error(changeset, field, message)
    end
  end

  def open_constraint(changeset, field) do
    auction_id = get_change(changeset, :auction_id, 0)

    if Auctions.open?(auction_id) in [nil, true] do
      changeset
    else
      add_error(changeset, field, "auction is not open")
    end
  end
end
