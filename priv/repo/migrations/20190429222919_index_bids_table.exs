defmodule Renaissance.Repo.Migrations.IndexBidsTable do
  use Ecto.Migration

  def up do
    create(index(:bids, [:auction_id]))
  end

  def down do
    drop(index(:bids, [:auction_id]))
  end
end
