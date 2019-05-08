defmodule Renaissance.Repo.Migrations.CreateBids do
  use Ecto.Migration

  def change do
    create table(:bids) do
      add :auction_id, references(:auctions), null: false
      add :bidder_id, references(:users), null: false
      add :amount, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
