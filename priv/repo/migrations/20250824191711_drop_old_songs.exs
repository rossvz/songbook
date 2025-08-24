defmodule Songbook.Repo.Migrations.DropOldSongs do
  use Ecto.Migration

  def change do
    drop table(:songs)
  end
end
