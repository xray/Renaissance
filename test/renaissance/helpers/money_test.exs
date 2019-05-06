defmodule Renaissance.Test.MoneyTest do
  use Renaissance.DataCase
  alias Renaissance.Helpers

  describe "is_money_type?/1" do
    test "true if given" do
      assert Helpers.Money.amount?(Money.new(175))
      assert Helpers.Money.amount?(Money.new(1_05))
      assert Helpers.Money.amount?(Money.new(5002_08))
    end

    test "true if int" do
      assert Helpers.Money.amount?(175)
      assert Helpers.Money.amount?(0)
    end

    test "false otherwise" do
      refute Helpers.Money.amount?(nil)
      refute Helpers.Money.amount?(true)
      refute Helpers.Money.amount?(0.01)
      refute Helpers.Money.amount?("1")
    end
  end

  describe "max_amount/2" do
    test "returns larger when distinct amounts, irrespective of param order" do
      one_cent = Money.new(0_01)
      dollar_and_one = Money.new(1_01)

      assert Helpers.Money.money_max(one_cent, dollar_and_one) == dollar_and_one
      assert Helpers.Money.money_max(dollar_and_one, one_cent) == dollar_and_one
    end

    test "returns larger when comparable, and distinct, params" do
      dollar = 100
      dollar_and_one = Money.new(1_01)

      assert Helpers.Money.money_max(dollar, dollar_and_one) == dollar_and_one
      assert Helpers.Money.money_max(dollar_and_one, dollar) == dollar_and_one
    end

    test "returns larger as Money type when valid params" do
      dollar = 100
      ten_cents = Money.new(0_01)

      assert Helpers.Money.money_max(dollar, ten_cents) == Money.new(dollar)
      assert Helpers.Money.money_max(ten_cents, dollar) != dollar
    end

    test "returns first when equal amounts " do
      no_underscore = Money.new(175)
      with_underscore = Money.new(1_75)

      assert Helpers.Money.money_max(no_underscore, with_underscore) == no_underscore
      assert Helpers.Money.money_max(with_underscore, no_underscore) == with_underscore
    end

    test "returns the valid amount if comparing value and nil values" do
      ten_dollars = Money.new(10_00)
      assert Helpers.Money.money_max(ten_dollars, nil) == ten_dollars
      assert Helpers.Money.money_max(nil, ten_dollars) == ten_dollars
    end

    test "returns nil when incomparable types" do
      ten_dollars = Money.new(10_00)

      assert Helpers.Money.money_max(ten_dollars, "7") == nil
      assert Helpers.Money.money_max(nil, nil) == nil
      assert Helpers.Money.money_max(7, 7.00) == nil
      assert Helpers.Money.money_max(ten_dollars, 7.00) == nil
      assert Helpers.Money.money_max("7", 7.00) == nil
    end
  end
end
