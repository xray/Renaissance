defmodule Renaissance.Auction do
  use Ecto.Schema
  alias Renaissance.{User}
  import Ecto.Changeset

  @required_fields ~w(title description user_id price end_date)a
  @optional_fields ~w()a

  schema "auctions" do
    field :title, :string
    field :description, :string
    field :price, Money.Ecto.Amount.Type
    field :end_date, :utc_datetime
    belongs_to :user, User

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

    if Money.compare(item_price || one_dollar, zero_dollars) == 1 do
      changeset
    else
      add_error(changeset, :price, "Price needs to be greater than 0.")
    end
  end

  defp validate_date(changeset) do
    auction_complete = get_change(changeset, :end_date)

    if DateTime.compare(DateTime.utc_now(), auction_complete || DateTime.utc_now()) == :lt do
      changeset
    else
      add_error(changeset, :end_date, "End date needs to be in the future.")
    end
  end
end
