defmodule Songbook.MusicFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Songbook.Music` context.
  """

  @doc """
  Generate a song.
  """
  def track_fixture(attrs \\ %{}) do
    {:ok, track} =
      attrs
      |> Enum.into(%{
        album: "some album",
        album_artwork_url: "some album_artwork_url",
        artist: "some artist",
        spotify_id: "some spotify_id",
        title: "some title"
      })
      |> Songbook.Music.create_track()

    track
  end
end
