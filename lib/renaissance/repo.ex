defmodule Renaissance.Repo do
  use Ecto.Repo,
    otp_app: :renaissance,
    adapter: Ecto.Adapters.Postgres
end
