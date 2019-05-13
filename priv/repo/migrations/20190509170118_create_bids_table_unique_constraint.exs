defmodule Renaissance.Repo.Migrations.CreateBidsTableUniqueConstraint do
  use Ecto.Migration

  def up do
    create unique_index(:bids, [:amount, :auction_id], name: :bids_amount_auction_id_index)
  end

  def down do
    drop unique_index(:bids, [:amount, :auction_id], name: :bids_amount_auction_id_index)
  end
end
