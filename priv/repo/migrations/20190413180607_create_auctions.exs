defmodule Renaissance.Repo.Migrations.CreateAuctions do
  use Ecto.Migration

  def change do
    create table(:auctions) do
      add :title, :string
      add :description, :string
      add :user_id, references(:users)
      add :price, :integer
      add :end_date, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
