defmodule Renaissance.Repo.Migrations.RenameAuctionsTablePrice do
  use Ecto.Migration

  def up do
    rename table(:auctions), :price, to: :starting_amount
  end

  def down do
    rename table(:auctions), :starting_amount, to: :price
  end
end
