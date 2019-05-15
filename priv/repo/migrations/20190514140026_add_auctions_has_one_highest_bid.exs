defmodule Renaissance.Repo.Migrations.AddAuctionsHasOneHighestBid do
  use Ecto.Migration

  def change do
    alter table(:auctions) do
      add :highest_bid, references(:bids)
    end
  end
end
