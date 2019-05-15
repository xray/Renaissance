defmodule Renaissance.Test.AuctionTest do
  use Renaissance.DataCase

  require Ecto.Query
  alias Renaissance.Auction

  def fixture(:valid_params) do
    {:ok, datetime, 0} = DateTime.from_iso8601("2149-04-21T12:00:00+0000")

    %{
      title: "Test title",
      description: "Test description",
      seller_id: 1,
      starting_amount: 100,
      end_auction_at: datetime
    }
  end

  describe "user" do
    test "accepts valid params" do
      changeset = Auction.changeset(%Auction{}, fixture(:valid_params))
      assert changeset.valid? == true
    end

    test "requires title" do
      invalid_params = %{fixture(:valid_params) | title: ""}
      changeset = Auction.changeset(%Auction{}, invalid_params)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).title
    end

    test "requires description" do
      invalid_params = %{fixture(:valid_params) | description: ""}
      changeset = Auction.changeset(%Auction{}, invalid_params)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).description
    end

    test "requires seller id" do
      invalid_params = %{fixture(:valid_params) | seller_id: nil}
      changeset = Auction.changeset(%Auction{}, invalid_params)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).seller_id
    end

    test "requires price" do
      invalid_params = %{fixture(:valid_params) | starting_amount: nil}
      changeset = Auction.changeset(%Auction{}, invalid_params)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).starting_amount
    end

    test "requires price to be greater than 0" do
      invalid_params = %{fixture(:valid_params) | starting_amount: 0}
      changeset = Auction.changeset(%Auction{}, invalid_params)

      refute changeset.valid?
      assert "must be greater than $0.00" in errors_on(changeset).starting_amount
    end

    test "requires end date" do
      invalid_params = %{fixture(:valid_params) | end_auction_at: nil}
      changeset = Auction.changeset(%Auction{}, invalid_params)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).end_auction_at
    end

    test "requires end date to be in the future" do
      {:ok, past_datetime, 0} = DateTime.from_iso8601("2019-01-01T12:00:00+0000")
      invalid_params = %{fixture(:valid_params) | end_auction_at: past_datetime}
      changeset = Auction.changeset(%Auction{}, invalid_params)

      refute changeset.valid?
      assert "should be in the future" in errors_on(changeset).end_auction_at
    end
  end
end
