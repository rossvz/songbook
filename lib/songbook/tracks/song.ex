defmodule Songbook.Tracks.Song do
  use Ecto.Schema
  import Ecto.Changeset

  schema "songs" do
    field :title, :string
    field :artist, :string
    field :album, :string
    field :album_artwork_url, :string
    field :spotify_id, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(song, attrs) do
    song
    |> cast(attrs, [:title, :artist, :album, :album_artwork_url, :spotify_id])
    |> validate_required([:title, :artist, :album, :album_artwork_url, :spotify_id])
  end
end
