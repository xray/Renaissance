defmodule Renaissance.Test.MoneyTest do
  use Renaissance.DataCase
  alias Renaissance.Helpers

  @one_cent Money.new(0_01)
  @dollar Money.new(100)
  @dollar_and_one Money.new(1_01)
  @underscore %{none: Money.new(175), with: Money.new(1_75)}

  describe "compare/2" do
    test "less than ( $0.01 is less than $1.01 )" do
      assert Helpers.Money.compare(@one_cent, @dollar_and_one) == :lt
    end

    test "greater than ( $1.01 is greater than $0.01 )" do
      assert Helpers.Money.compare(@dollar_and_one, @one_cent) == :gt
    end

    test "equal ( $1.75 is equal to $1.75 )" do
      assert Helpers.Money.compare(@underscore.none, @underscore.with) == :eq
      assert Helpers.Money.compare(@underscore.with, @underscore.none) == :eq
    end
  end

  describe "max_amount/2" do
    test "returns larger when distinct amounts, irrespective of param order" do
      assert Helpers.Money.money_max(@one_cent, @dollar_and_one) == @dollar_and_one
      assert Helpers.Money.money_max(@dollar_and_one, @one_cent) == @dollar_and_one
    end

    test "returns larger when comparable, and distinct, params" do
      assert Helpers.Money.money_max(@dollar, @dollar_and_one) == @dollar_and_one
      assert Helpers.Money.money_max(@dollar_and_one, @dollar) == @dollar_and_one
    end

    test "returns first when equal amounts " do
      assert Helpers.Money.money_max(@underscore.none, @underscore.with) == @underscore.none
      assert Helpers.Money.money_max(@underscore.with, @underscore.none) == @underscore.with
    end
  end

  describe "to_float/1" do
    test "returns a float of 9.99 when given a money object with a value of 999" do
      value = Money.new(999).amount
      assert Helpers.Money.to_float(value) == 9.99
    end

    test "returns a float of 9.00 when given a money object with a value of 900" do
      value = Money.new(900).amount
      assert Helpers.Money.to_float(value) == 9.00
    end
  end

  describe "to_money!/2" do
    test "given a string of '5.0' it returns a money object with a value of 500" do
      to_convert = %{amount: "5.0"}
      control = Money.new(500)

      result = Helpers.Money.to_money!(to_convert, :amount).amount

      assert Money.compare(control, result) == 0
    end

    test "given a string of '5' it returns a money object with a value of 500" do
      to_convert = %{amount: "5"}
      control = Money.new(500)

      result = Helpers.Money.to_money!(to_convert, :amount).amount

      assert Money.compare(control, result) == 0
    end

    test "given a string of '5.00' it returns a money object with a value of 500" do
      to_convert = %{amount: "5.00"}
      control = Money.new(500)

      result = Helpers.Money.to_money!(to_convert, :amount).amount

      assert Money.compare(control, result) == 0
    end

    test "given a string of '.5' it returns a money object with a value of 50" do
      to_convert = %{amount: ".5"}
      control = Money.new(50)

      result = Helpers.Money.to_money!(to_convert, :amount).amount

      assert Money.compare(control, result) == 0
    end

    test "given a string of '.49 it returns a money object with a value of 49" do
      to_convert = %{amount: ".49"}
      control = Money.new(49)

      result = Helpers.Money.to_money!(to_convert, :amount).amount

      assert Money.compare(control, result) == 0
    end

    test "given a string of '.05' it returns a money object with a value of 49" do
      to_convert = %{amount: ".05"}
      control = Money.new(5)

      result = Helpers.Money.to_money!(to_convert, :amount).amount

      assert Money.compare(control, result) == 0
    end
  end
end
