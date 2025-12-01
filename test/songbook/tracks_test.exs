defmodule Songbook.TracksTest do
  use Songbook.DataCase

  import Songbook.MusicFixtures

  alias Songbook.Music

  describe "tracks" do
    alias Songbook.Music.Track

    @invalid_attrs %{title: nil, artist: nil, album: nil, album_artwork_url: nil, spotify_id: nil}

    test "list_tracks/0 returns all tracks" do
      track = track_fixture()
      tracks = Music.list_tracks!()
      assert length(tracks) == 1
      assert hd(tracks).id == track.id
      assert hd(tracks).vote_count == 0
    end

    test "list_tracks/0 returns the tracks sorted by votes" do
      track1 = track_fixture()
      track2 = track_fixture()
      track3 = track_fixture()

      # Cast votes for each track
      Music.cast_vote(%{voter_id: "voter1", track_id: track1.id})

      Music.cast_vote(%{voter_id: "voter2", track_id: track2.id})
      Music.cast_vote(%{voter_id: "voter3", track_id: track2.id})
      Music.cast_vote(%{voter_id: "voter4", track_id: track2.id})
      Music.cast_vote(%{voter_id: "voter5", track_id: track2.id})
      Music.cast_vote(%{voter_id: "voter6", track_id: track2.id})

      Music.cast_vote(%{voter_id: "voter7", track_id: track3.id})
      Music.cast_vote(%{voter_id: "voter8", track_id: track3.id})
      Music.cast_vote(%{voter_id: "voter9", track_id: track3.id})
      Music.cast_vote(%{voter_id: "voter10", track_id: track3.id})
      Music.cast_vote(%{voter_id: "voter11", track_id: track3.id})
      Music.cast_vote(%{voter_id: "voter12", track_id: track3.id})
      Music.cast_vote(%{voter_id: "voter13", track_id: track3.id})
      Music.cast_vote(%{voter_id: "voter14", track_id: track3.id})
      Music.cast_vote(%{voter_id: "voter15", track_id: track3.id})
      Music.cast_vote(%{voter_id: "voter16", track_id: track3.id})
      Music.cast_vote(%{voter_id: "voter17", track_id: track3.id})
      Music.cast_vote(%{voter_id: "voter18", track_id: track3.id})

      tracks = Music.list_tracks!()
      assert length(tracks) == 3
      assert Enum.at(tracks, 0).id == track3.id
      assert Enum.at(tracks, 0).vote_count == 12
      assert Enum.at(tracks, 1).id == track2.id
      assert Enum.at(tracks, 1).vote_count == 5
      assert Enum.at(tracks, 2).id == track1.id
      assert Enum.at(tracks, 2).vote_count == 1
    end

    test "get_track!/1 returns the track with given id" do
      track = track_fixture()
      fetched = Music.get_track!(track.id)
      assert fetched.id == track.id
      assert fetched.vote_count == 0
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

    test "cast_vote/1 creates a vote for a track" do
      track = track_fixture()
      voter_id = "test-voter"

      assert {:ok, _vote} = Music.cast_vote(%{voter_id: voter_id, track_id: track.id})

      updated_track = Music.get_track!(track.id)
      assert updated_track.vote_count == 1
    end

    test "cast_vote/1 prevents duplicate votes from same voter" do
      track = track_fixture()
      voter_id = "test-voter"

      {:ok, _vote} = Music.cast_vote(%{voter_id: voter_id, track_id: track.id})

      # Second vote from same voter should fail
      assert {:error, _} = Music.cast_vote(%{voter_id: voter_id, track_id: track.id})

      updated_track = Music.get_track!(track.id)
      assert updated_track.vote_count == 1
    end

    test "reset_votes/1 resets all votes for a track to 0" do
      track = track_fixture()

      # Cast some votes
      Music.cast_vote(%{voter_id: "voter1", track_id: track.id})
      Music.cast_vote(%{voter_id: "voter2", track_id: track.id})
      Music.cast_vote(%{voter_id: "voter3", track_id: track.id})

      # Verify votes exist
      assert Music.get_track!(track.id).vote_count == 3

      # Reset votes
      {:ok, _} = Music.reset_votes(track)

      # Verify votes are gone
      assert Music.get_track!(track.id).vote_count == 0
    end

    test "delete_track/1 deletes the track" do
      track = track_fixture()
      assert Music.delete_track(track) == :ok
    end

    test "list_visible_tracks!/0 returns only non-hidden tracks" do
      visible_track = track_fixture()
      hidden_track = track_fixture(%{hidden: true})

      tracks = Music.list_visible_tracks!()
      assert length(tracks) == 1
      assert hd(tracks).id == visible_track.id
      refute Enum.any?(tracks, fn t -> t.id == hidden_track.id end)
    end

    test "toggle_visibility/1 hides a visible track" do
      track = track_fixture()
      assert track.hidden == false

      {:ok, updated_track} = Music.toggle_visibility(track)
      assert updated_track.hidden == true
    end

    test "toggle_visibility/1 shows a hidden track" do
      track = track_fixture(%{hidden: true})
      assert track.hidden == true

      {:ok, updated_track} = Music.toggle_visibility(track)
      assert updated_track.hidden == false
    end
  end
end
