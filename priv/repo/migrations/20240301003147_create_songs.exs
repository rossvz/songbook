defmodule Songbook.Repo.Migrations.CreateSongs do
  use Ecto.Migration

  def change do
    create table(:songs) do
      add :title, :string
      add :artist, :string
      add :album, :string
      add :album_artwork_url, :string
      add :spotify_id, :string

      timestamps(type: :utc_datetime)
    end
  end
end
