defmodule Renaissance.Helpers.Validate do
  import Ecto.Changeset

  def validate_amount(changeset, field_name) do
    {_, amount} = Money.Ecto.Amount.Type.dump(get_change(changeset, field_name, 0))

    if amount > 0 do
      changeset
    else
      add_error(changeset, field_name, "must be greater than 0")
    end
  end
end
