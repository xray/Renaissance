defmodule Renaissance.Helpers.Money do
  defp extract_amount(nil), do: "000"
  defp extract_amount(string), do: string

  def to_money!(params, name) do
    amount =
      extract_amount(params[name])
      |> String.replace(".", "")
      |> String.to_integer()
      |> Money.new()

    Map.replace!(params, name, amount)
  end

  def money?(%Money{}), do: true
  def money?(p), do: is_integer(p)

  def to_money(m) do
    if money?(m) do
      if is_integer(m), do: Money.new(m), else: m
    end
  end

  def compare(nil, _), do: nil
  def compare(_, nil), do: nil

  def compare(m1, m2) do
    # Wrapper for readability
    case Money.compare(m1, m2) do
      -1 -> :lt
      0 -> :eq
      1 -> :gt
    end
  end

  def money_max(m1, m2) do
    if compare(m1, m2) == :lt, do: m2, else: m1
  end
end
