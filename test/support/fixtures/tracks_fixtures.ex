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

  @doc """
  Generate a show.
  """
  def show_fixture(attrs \\ %{}) do
    {:ok, show} =
      attrs
      |> Enum.into(%{
        date: ~D[2025-12-31],
        time: "8:00 PM",
        venue: "The Blue Note",
        latitude: Decimal.new("40.7128"),
        longitude: Decimal.new("-74.0060")
      })
      |> Songbook.Music.create_show()

    show
  end
end
