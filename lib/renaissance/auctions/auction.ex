defmodule Renaissance.Auction do
    use Ecto.Schema
    import Ecto.Changeset
  
    schema "auctions" do
      field :title, :string
      field :description, :string
      field :user_id, :integer
      field :price, Money.Ecto.Amount.Type
      field :end_date, :utc_datetime
  
      timestamps(type: :utc_datetime)
    end
  
    @doc false
    def changeset(user, attrs \\ %{}) do
      user
      |> cast(attrs, [:title, :description, :user_id, :price, :end_date])
      |> validate_required([:title, :description, :user_id, :price, :end_date])
      |> validate_price()
      |> validate_date()
    end

    defp validate_price(changeset) do
      item_price = get_change(changeset, :price)
      zero_dollars = Money.new(000, :USD)
      one_dollar = Money.new(100, :USD)

      case Money.compare(item_price || one_dollar, zero_dollars) do
        0 ->
          add_error(changeset, :price, "Price needs to be greater than 0.")
        -1 ->
          add_error(changeset, :price, "Price needs to be greater than 0.")
        1 -> 
          changeset
      end
    end

    defp validate_date(changeset) do
      auction_complete = get_change(changeset, :end_date)

      case DateTime.compare(DateTime.utc_now(), auction_complete || DateTime.utc_now()) == :lt do
        true -> 
          changeset
        false -> 
          add_error(changeset, :end_date, "End date needs to be in the future.")
      end
    end
  end
  