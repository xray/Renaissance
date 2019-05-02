defmodule Renaissance.Test.CompareTest do
  use Renaissance.DataCase
  alias Renaissance.Helpers.Compare

  describe "is_money_type?/1" do
    test "true if given" do
      assert Compare.amount?(Money.new(175)) == true
      assert Compare.amount?(Money.new(1_05)) == true
      assert Compare.amount?(Money.new(5002_08)) == true
    end

    test "true if int" do
      assert Compare.amount?(175) == true
      assert Compare.amount?(0) == true
    end

    test "false otherwise" do
      assert Compare.amount?(nil) == false
      assert Compare.amount?(true) == false
      assert Compare.amount?(0.01) == false
      assert Compare.amount?("1") == false
    end
  end

  describe "max_amount/2" do
    test "returns larger when distinct amounts, irrespective of param order" do
      one_cent = Money.new(0_01)
      dollar_and_one = Money.new(1_01)

      assert Compare.money_max(one_cent, dollar_and_one) == dollar_and_one
      assert Compare.money_max(dollar_and_one, one_cent) == dollar_and_one
    end

    test "returns larger when comparable, and distinct, params" do
      dollar = 100
      dollar_and_one = Money.new(1_01)

      assert Compare.money_max(dollar, dollar_and_one) == dollar_and_one
      assert Compare.money_max(dollar_and_one, dollar) == dollar_and_one
    end

    test "returns larger as Money type when valid params" do
      dollar = 100
      ten_cents = Money.new(0_01)

      assert Compare.money_max(dollar, ten_cents) == Money.new(dollar)
      assert Compare.money_max(ten_cents, dollar) != dollar
    end

    test "returns first when equal amounts " do
      no_underscore = Money.new(175)
      with_underscore = Money.new(1_75)

      assert Compare.money_max(no_underscore, with_underscore) == no_underscore
      assert Compare.money_max(with_underscore, no_underscore) == with_underscore
    end

    test "returns the valid amount if comparing value and nil values" do
      ten_dollars = Money.new(10_00)
      assert Compare.money_max(ten_dollars, nil) == ten_dollars
      assert Compare.money_max(nil, ten_dollars) == ten_dollars
    end

    test "returns nil when incomparable types" do
      ten_dollars = Money.new(10_00)

      assert Compare.money_max(ten_dollars, "7") == nil
      assert Compare.money_max(nil, nil) == nil
      assert Compare.money_max(7, 7.00) == nil
      assert Compare.money_max(ten_dollars, 7.00) == nil
      assert Compare.money_max("7", 7.00) == nil
    end
  end
end
