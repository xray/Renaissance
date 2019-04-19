defmodule Renaissance.Test.AuctionTest do
  use Renaissance.DataCase

  require Ecto.Query
  alias Renaissance.Auction

  @now DateTime.utc_now()
  @after_one_day %{@now | day: @now.day + 1}

  @valid_params %{
    title: "Test title",
    description: "Test description",
    seller_id: 1,
    price: 100,
    end_auction_at: @after_one_day
  }

  describe "user" do
    test "accepts valid params" do
      changeset = Auction.changeset(%Auction{}, @valid_params)
      assert changeset.valid? == true
    end

    test "requires title" do
      invalid_params = Map.put(@valid_params, :title, "")
      changeset = Auction.changeset(%Auction{}, invalid_params)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).title
    end

    test "requires description" do
      invalid_params = Map.put(@valid_params, :description, "")
      changeset = Auction.changeset(%Auction{}, invalid_params)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).description
    end

    test "requires user id" do
      invalid_params = Map.put(@valid_params, :seller_id, nil)
      changeset = Auction.changeset(%Auction{}, invalid_params)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).seller_id
    end

    test "requires price" do
      invalid_params = Map.put(@valid_params, :price, nil)
      changeset = Auction.changeset(%Auction{}, invalid_params)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).price
    end

    test "requires price to be greater than 0" do
      invalid_params = Map.put(@valid_params, :price, 0)
      changeset = Auction.changeset(%Auction{}, invalid_params)

      refute changeset.valid?
      assert "must be greater than 0" in errors_on(changeset).price
    end

    test "requires end date" do
      invalid_params = Map.put(@valid_params, :end_auction_at, nil)
      changeset = Auction.changeset(%Auction{}, invalid_params)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).end_auction_at
    end

    test "requires future end date" do
      {:ok, datetime, 0} = DateTime.from_iso8601("2019-01-01T12:00:00+0000")
      invalid_params = Map.put(@valid_params, :end_auction_at, datetime)
      changeset = Auction.changeset(%Auction{}, invalid_params)

      refute changeset.valid?
      assert "should be in the future" in errors_on(changeset).end_auction_at
    end
  end
end
