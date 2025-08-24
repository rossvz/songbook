defmodule Songbook.TracksTest do
  use Songbook.DataCase

  import Songbook.MusicFixtures
  import Ash.Test

  alias Songbook.Music

  describe "tracks" do
    alias Songbook.Music.Track

    @invalid_attrs %{title: nil, artist: nil, album: nil, album_artwork_url: nil, spotify_id: nil}

    test "list_tracks/0 returns all tracks" do
      track = track_fixture()
      assert_stripped Music.list_tracks!() == [track]
    end

    test "list_tracks/0 returns the tracks sorted by votes" do
      track1 = track_fixture(%{votes: 1})
      track2 = track_fixture(%{votes: 5})
      track3 = track_fixture(%{votes: 12})

      assert_stripped Music.list_tracks!() == [track3, track2, track1]
    end

    test "get_track!/1 returns the track with given id" do
      track = track_fixture()
      assert_stripped Music.get_track!(track.id) == track
    end

    test "create_track/1 with valid data creates a track" do
      valid_attrs = %{
        title: "some title",
        artist: "some artist",
        album: "some album",
        album_artwork_url: "some album_artwork_url",
        spotify_id: "some spotify_id"
      }

      assert {:ok, %Track{} = track} = Music.create_track(valid_attrs)
      assert track.title == "some title"
      assert track.artist == "some artist"
      assert track.album == "some album"
      assert track.album_artwork_url == "some album_artwork_url"
      assert track.spotify_id == "some spotify_id"
    end

    test "create_track/1 with invalid data returns error changeset" do
      assert {:error, %Ash.Error.Invalid{}} = Music.create_track(@invalid_attrs)
    end

    test "upvote_track/1 increases the votes by 1" do
      track = track_fixture()
      Music.upvote_track(track)
      assert Music.get_track!(track.id).votes == 1
    end

    test "downvote_track/1 decreases the votes by 1" do
      track = track_fixture()
      assert Music.downvote_track(track) == {:ok, %{track | votes: -1}}
      assert Music.get_track!(track.id).votes == -1
    end

    test "reset_votes/1 resets the votes to 0" do
      track = track_fixture()
      assert Music.reset_votes(track) == {:ok, %{track | votes: 0}}
      assert Music.get_track!(track.id).votes == 0
    end

    test "delete_track/1 deletes the track" do
      track = track_fixture()
      assert Music.delete_track(track) == :ok
    end
  end
end
