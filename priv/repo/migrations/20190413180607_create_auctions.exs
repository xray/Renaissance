defmodule Renaissance.Repo.Migrations.CreateAuctions do
  use Ecto.Migration

  def change do
    create table(:auctions) do
      add :title, :string, null: false
      add :description, :string
      add :user_id, references(:users), null: false
      add :price, :integer
      add :end_auction_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
