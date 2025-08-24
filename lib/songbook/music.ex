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

      define :upvote_track, action: :upvote_track
      define :downvote_track, action: :downvote_track
      define :reset_votes, action: :reset_votes

      define :delete_track, action: :destroy
    end
  end
end
