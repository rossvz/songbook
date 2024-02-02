defmodule Songbook.Repo do
  use Ecto.Repo,
    otp_app: :songbook,
    adapter: Ecto.Adapters.Postgres
end
