defmodule Renaissance.Helpers.Compare do
  alias Renaissance.Helpers.Adapt

  def amount?(%Money{}), do: true

  def amount?(p) do
    if is_integer(p), do: true, else: false
  end

  def money_max(m1, m2) do
    cond do
      amount?(m1) && amount?(m2) == true ->
        if Adapt.money_value(m1) >= Adapt.money_value(m2) do
          return_money_max(m1)
        else
          return_money_max(m2)
        end

      amount?(m1) == true && is_nil(m2) ->
        return_money_max(m1)

      amount?(m2) == true && is_nil(m1) ->
        return_money_max(m2)

      true ->
        nil
    end
  end

  defp return_money_max(m) do
    if is_integer(m), do: Money.new(m), else: m
  end
end
