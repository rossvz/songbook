defmodule Songbook.TracksTest do
  use Songbook.DataCase

  alias Songbook.Music

  describe "songs" do
    import Songbook.TracksFixtures

    alias Songbook.Music.Track

    @invalid_attrs %{title: nil, artist: nil, album: nil, album_artwork_url: nil, spotify_id: nil}

    test "list_songs/0 returns all songs" do
      song = song_fixture()
      assert Music.list_tracks() == [song]
    end

    test "get_song!/1 returns the song with given id" do
      song = song_fixture()
      assert Music.get_track!(song.id) == song
    end

    test "create_song/1 with valid data creates a song" do
      valid_attrs = %{
        title: "some title",
        artist: "some artist",
        album: "some album",
        album_artwork_url: "some album_artwork_url",
        spotify_id: "some spotify_id"
      }

      assert {:ok, %Track{} = song} = Music.create_track(valid_attrs)
      assert song.title == "some title"
      assert song.artist == "some artist"
      assert song.album == "some album"
      assert song.album_artwork_url == "some album_artwork_url"
      assert song.spotify_id == "some spotify_id"
    end

    test "create_song/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Music.create_track(@invalid_attrs)
    end

    test "update_song/2 with valid data updates the song" do
      song = song_fixture()

      update_attrs = %{
        title: "some updated title",
        artist: "some updated artist",
        album: "some updated album",
        album_artwork_url: "some updated album_artwork_url",
        spotify_id: "some updated spotify_id"
      }

      assert {:ok, %Track{} = song} = Music.update_track(song, update_attrs)
      assert song.title == "some updated title"
      assert song.artist == "some updated artist"
      assert song.album == "some updated album"
      assert song.album_artwork_url == "some updated album_artwork_url"
      assert song.spotify_id == "some updated spotify_id"
    end

    test "update_song/2 with invalid data returns error changeset" do
      song = song_fixture()
      assert {:error, %Ecto.Changeset{}} = Music.update_track(song, @invalid_attrs)
      assert song == Music.get_track!(song.id)
    end

    test "delete_song/1 deletes the song" do
      song = song_fixture()
      assert {:ok, %Track{}} = Music.delete_track(song)
      assert_raise Ecto.NoResultsError, fn -> Music.get_track!(song.id) end
    end

    test "change_song/1 returns a song changeset" do
      song = song_fixture()
      assert %Ecto.Changeset{} = Music.change_track(song)
    end
  end
end
