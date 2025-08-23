defmodule Songbook.Repo.Migrations.AddVotesToSongs do
  use Ecto.Migration

  def change do
    alter table(:songs) do
      add :votes, :integer, default: 0
    end
  end
end
