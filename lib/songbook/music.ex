defmodule Songbook.Music do
  @moduledoc false
  use Ash.Domain,
    otp_app: :songbook,
    extensions: [AshPhoenix]

  resources do
    resource Songbook.Music.Track do
      define :list_tracks, action: :read
      define :get_track, action: :read, get_by: :id
      define :get_track_by_spotify_id, action: :read, get_by: :spotify_id
      define :create_track, action: :create

      define :reset_votes, action: :reset_votes

      define :delete_track, action: :destroy
    end

    resource Songbook.Music.Vote do
      define :cast_vote, action: :cast_vote
      define :list_votes, action: :read
      define :get_votes_by_voter, action: :read, get_by: :voter_id
      define :has_voted?, action: :read, get_by: [:voter_id, :track_id]
    end
  end
end
