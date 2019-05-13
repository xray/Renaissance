defmodule Renaissance.Helpers.Validators do
  import Ecto.Changeset
  alias Renaissance.{Auctions, Helpers}

  def validate_amount(changeset, field, current \\ nil) do
    proposed = get_change(changeset, field)
    current = get_current_amount(changeset, current)

    if Helpers.Money.compare(proposed, current) in [:lt, :eq] do
      add_error(changeset, field, ~s(must be greater than #{current}))
    else
      changeset
    end
  end

  defp get_current_amount(changeset, current) do
    if !is_nil(current) and is_integer(current) do
      Money.new(current)
    else
      get_change(changeset, :auction_id)
      |> Auctions.get_current_amount()
    end
  end

  def validate_bidder(changeset, field) do
    bidder_id = get_change(changeset, field)
    seller_id = get_change(changeset, :auction_id) |> Auctions.get_seller_id()

    if seller_id == bidder_id do
      add_error(changeset, field, "can't bid on the item you're selling")
    else
      changeset
    end
  end

  def validate_open(changeset, field) do
    auction_id = get_change(changeset, :auction_id)

    if Auctions.exists?(auction_id) and !Auctions.open?(auction_id) do
      add_error(changeset, field, "auction is not open")
    else
      changeset
    end
  end
end
