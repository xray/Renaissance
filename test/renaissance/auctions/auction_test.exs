defmodule Renaissance.Test.AuctionTest do
  use Renaissance.DataCase

  require Ecto.Query
  alias Renaissance.Auction

  describe "user" do
    test "requires title" do
      {:ok, datetime, 0} = DateTime.from_iso8601("2019-04-21T12:00:00+0000")

      changeset =
        Auction.changeset(
          %Auction{},
          %{
            title: "",
            description: "Test description",
            user_id: 1,
            price: 100,
            end_date: datetime
          }
        )

      refute changeset.valid?
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end

    test "requires description" do
      {:ok, datetime, 0} = DateTime.from_iso8601("2019-04-21T12:00:00+0000")

      changeset =
        Auction.changeset(
          %Auction{},
          %{
            title: "Test title",
            description: "",
            user_id: 1,
            price: 100,
            end_date: datetime
          }
        )

      refute changeset.valid?
      assert %{description: ["can't be blank"]} = errors_on(changeset)
    end

    test "requires user id" do
      {:ok, datetime, 0} = DateTime.from_iso8601("2019-04-21T12:00:00+0000")

      changeset =
        Auction.changeset(
          %Auction{},
          %{
            title: "Test title",
            description: "Test description",
            user_id: nil,
            price: 100,
            end_date: datetime
          }
        )

      refute changeset.valid?
      assert %{user_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "requires price" do
      {:ok, datetime, 0} = DateTime.from_iso8601("2019-04-21T12:00:00+0000")

      changeset =
        Auction.changeset(
          %Auction{},
          %{
            title: "Test title",
            description: "Test description",
            user_id: 1,
            price: nil,
            end_date: datetime
          }
        )

      refute changeset.valid?
      assert %{price: ["can't be blank"]} = errors_on(changeset)
    end

    test "requires end date" do
      changeset =
        Auction.changeset(
          %Auction{},
          %{
            title: "Test title",
            description: "Test description",
            user_id: 1,
            price: 100,
            end_date: nil
          }
        )

      refute changeset.valid?
      assert %{end_date: ["can't be blank"]} = errors_on(changeset)
    end

    test "requires price to be greater than 0" do
      {:ok, datetime, 0} = DateTime.from_iso8601("2019-04-21T12:00:00+0000")

      changeset =
        Auction.changeset(
          %Auction{},
          %{
            title: "Test title",
            description: "Test description",
            user_id: 1,
            price: 0,
            end_date: datetime
          }
        )

      refute changeset.valid?
      assert %{price: ["Price needs to be greater than 0."]} = errors_on(changeset)
    end

    test "requires end date to be in the future" do
      {:ok, datetime, 0} = DateTime.from_iso8601("2019-01-01T12:00:00+0000")

      changeset =
        Auction.changeset(
          %Auction{},
          %{
            title: "Test title",
            description: "Test description",
            user_id: 1,
            price: 100,
            end_date: datetime
          }
        )

      refute changeset.valid?
      assert %{end_date: ["End date needs to be in the future."]} = errors_on(changeset)
    end
  end
end
