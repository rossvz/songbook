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
  Generate a visible track with genres set.

  Note: genres are set via the `:set_genres` update action because the `:create`
  action doesn't accept `:genres`.
  """
  def track_with_genres_fixture(genres, attrs \\ %{}) when is_list(genres) do
    track = track_fixture(attrs)
    Songbook.Music.set_genres!(track, %{genres: genres})
  end

  @doc """
  Generate a hidden track (excluded from `list_visible_tracks!/0`).
  """
  def hidden_track_fixture(attrs \\ %{}) do
    track = track_fixture(attrs)
    {:ok, track} = Songbook.Music.toggle_visibility(track)
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
