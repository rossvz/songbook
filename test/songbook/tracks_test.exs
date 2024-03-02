defmodule Songbook.TracksTest do
  use Songbook.DataCase

  alias Songbook.Tracks

  describe "songs" do
    alias Songbook.Tracks.Song

    import Songbook.TracksFixtures

    @invalid_attrs %{title: nil, artist: nil, album: nil, album_artwork_url: nil, spotify_id: nil}

    test "list_songs/0 returns all songs" do
      song = song_fixture()
      assert Tracks.list_songs() == [song]
    end

    test "get_song!/1 returns the song with given id" do
      song = song_fixture()
      assert Tracks.get_song!(song.id) == song
    end

    test "create_song/1 with valid data creates a song" do
      valid_attrs = %{title: "some title", artist: "some artist", album: "some album", album_artwork_url: "some album_artwork_url", spotify_id: "some spotify_id"}

      assert {:ok, %Song{} = song} = Tracks.create_song(valid_attrs)
      assert song.title == "some title"
      assert song.artist == "some artist"
      assert song.album == "some album"
      assert song.album_artwork_url == "some album_artwork_url"
      assert song.spotify_id == "some spotify_id"
    end

    test "create_song/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracks.create_song(@invalid_attrs)
    end

    test "update_song/2 with valid data updates the song" do
      song = song_fixture()
      update_attrs = %{title: "some updated title", artist: "some updated artist", album: "some updated album", album_artwork_url: "some updated album_artwork_url", spotify_id: "some updated spotify_id"}

      assert {:ok, %Song{} = song} = Tracks.update_song(song, update_attrs)
      assert song.title == "some updated title"
      assert song.artist == "some updated artist"
      assert song.album == "some updated album"
      assert song.album_artwork_url == "some updated album_artwork_url"
      assert song.spotify_id == "some updated spotify_id"
    end

    test "update_song/2 with invalid data returns error changeset" do
      song = song_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracks.update_song(song, @invalid_attrs)
      assert song == Tracks.get_song!(song.id)
    end

    test "delete_song/1 deletes the song" do
      song = song_fixture()
      assert {:ok, %Song{}} = Tracks.delete_song(song)
      assert_raise Ecto.NoResultsError, fn -> Tracks.get_song!(song.id) end
    end

    test "change_song/1 returns a song changeset" do
      song = song_fixture()
      assert %Ecto.Changeset{} = Tracks.change_song(song)
    end
  end
end
