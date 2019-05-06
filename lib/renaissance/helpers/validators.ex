defmodule Renaissance.Helpers.Validators do
  import Ecto.Changeset
  alias Renaissance.Helpers
  alias Renaissance.Auctions

  def validate_amount(changeset, field) do
    auction_id = get_change(changeset, :auction_id, 0)

    proposed = get_change(changeset, field, 0) |> Helpers.Money.to_value()
    current = Auctions.get_current_amount(auction_id) |> Helpers.Money.to_value()

    if proposed > current do
      changeset
    else
      message = ~s(must be greater than #{Money.new(current)})
      add_error(changeset, field, message)
    end
  end

  def validate_bidder(changeset, field) do
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

  def validate_open(changeset, field) do
    auction_id = get_change(changeset, :auction_id, 0)

    if Auctions.open?(auction_id) in [nil, true] do
      changeset
    else
      add_error(changeset, field, "auction is not open")
    end
  end
end
