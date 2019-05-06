defmodule Renaissance.Helpers.Money do
  defp extract_amount(nil), do: "000"
  defp extract_amount(amount), do: amount

  def to_amount(params, name) do
    amount =
      extract_amount(params[name])
      |> String.replace(".", "")
      |> String.to_integer()
      |> Money.new()

    Map.replace!(params, name, amount)
  end

  def to_value(param) do
    {_, value} = Money.Ecto.Amount.Type.dump(param)
    value
  end

  def amount?(%Money{}), do: true
  def amount?(p), do: is_integer(p)

  def money_max(m1, m2) do
    cond do
      amount?(m1) && amount?(m2) == true ->
        if to_value(m1) >= to_value(m2), do: to_money(m1), else: to_money(m2)

      amount?(m1) == true && is_nil(m2) ->
        to_money(m1)

      amount?(m2) == true && is_nil(m1) ->
        to_money(m2)

      true ->
        nil
    end
  end

  defp to_money(m) do
    if is_integer(m), do: Money.new(m), else: m
  end
end
