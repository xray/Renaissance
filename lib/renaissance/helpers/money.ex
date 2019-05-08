defmodule Renaissance.Helpers.Money do
  defp extract_amount(nil), do: "000"
  defp extract_amount(string), do: string

  def to_money!(params, name) do
    amount =
      extract_amount(params[name])
      |> normalize_float
      |> String.replace(".", "")
      |> String.to_integer()
      |> Money.new()

    Map.replace!(params, name, amount)
  end

  def to_float(value) do
    value / 100
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

  defp normalize_float(float_as_string) do
    number_of_decimal_places =
      String.split(float_as_string, ".")
      |> Enum.count()

    secondary =
      case number_of_decimal_places do
        1 ->
          0

        _ ->
          float_as_string
          |> String.split(".")
          |> List.last()
          |> String.length()
      end

    case secondary do
      0 ->
        "#{float_as_string}.00"

      1 ->
        "#{float_as_string}0"

      2 ->
        float_as_string

      _ ->
        last_two_digits =
          float_as_string
          |> String.split(".")
          |> List.last()
          |> String.slice(0, 2)

        first_digits =
          float_as_string
          |> String.split(".")
          |> List.first()

        "#{first_digits}.#{last_two_digits}"
    end
  end
end
