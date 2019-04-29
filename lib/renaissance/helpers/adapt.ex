defmodule Renaissance.Helpers.Adapt do
  defp extract_amount(amount) do
    if is_nil(amount) do
      "000"
    else
      amount
    end
  end

  def format_amount(params, param_name) do
    amount =
      extract_amount(params[param_name])
      |> String.replace(".", "")
      |> String.to_integer()
      |> Money.new()

    Map.replace!(params, param_name, amount)
  end
end
