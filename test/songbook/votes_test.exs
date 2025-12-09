defmodule Songbook.VotesTest do
  use Songbook.DataCase

  import Songbook.MusicFixtures

  alias Songbook.Music

  describe "destroy_all_votes/0" do
    test "destroys all votes across multiple tracks" do
      track1 = track_fixture()
      track2 = track_fixture()

      Music.cast_vote(%{voter_id: "voter1", track_id: track1.id})
      Music.cast_vote(%{voter_id: "voter2", track_id: track1.id})
      Music.cast_vote(%{voter_id: "voter3", track_id: track2.id})

      assert Music.get_track!(track1.id).vote_count == 2
      assert Music.get_track!(track2.id).vote_count == 1

      {:ok, count} = Music.destroy_all_votes()

      assert count == 3
      assert Music.get_track!(track1.id).vote_count == 0
      assert Music.get_track!(track2.id).vote_count == 0
    end
  end
end
