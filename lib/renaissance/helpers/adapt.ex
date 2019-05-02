defmodule Renaissance.Helpers.Adapt do
  defp extract_amount(nil), do: "000"
  defp extract_amount(amount), do: amount

  def format_amount(params, name) do
    amount =
      extract_amount(params[name])
      |> String.replace(".", "")
      |> String.to_integer()
      |> Money.new()

    Map.replace!(params, name, amount)
  end

  def money_value(param) do
    {_, value} = Money.Ecto.Amount.Type.dump(param)
    value
  end
end
