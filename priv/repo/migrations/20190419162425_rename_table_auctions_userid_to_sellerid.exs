defmodule Renaissance.Repo.Migrations.RenameTableAuctionsUseridToSellerid do
  use Ecto.Migration

  def up do
    rename table(:auctions), :user_id, to: :seller_id
  end

  def down do
    rename table(:auctions), :seller_id, to: :user_id
  end
end
