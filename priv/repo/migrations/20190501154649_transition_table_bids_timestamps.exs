defmodule Renaissance.Repo.Migrations.TransitionTableBidsTimestamps do
  use Ecto.Migration

  def up do
    rename table(:bids), :inserted_at, to: :created_at

    alter table(:bids) do
      remove :updated_at, :timestamps
    end
  end

  def down do
    rename table(:bids), :created_at, to: :inserted_at

    alter table(:bids) do
      add :inserted_at, :utc_datetime, default: fragment("NOW()")
    end
  end
end
