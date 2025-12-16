defmodule Songbook.Music do
  @moduledoc false
  use Ash.Domain,
    otp_app: :songbook,
    extensions: [AshPhoenix]

  resources do
    resource Songbook.Music.Track do
      define :list_tracks, action: :read
      define :list_visible_tracks, action: :list_visible
      define :get_track, action: :read, get_by: :id
      define :get_track_by_spotify_id, action: :read, get_by: :spotify_id
      define :create_track, action: :create

      define :reset_votes, action: :reset_votes
      define :toggle_visibility, action: :toggle_visibility
      define :set_dominant_color, action: :set_dominant_color
      define :set_genres, action: :set_genres

      define :delete_track, action: :destroy
    end

    resource Songbook.Music.Vote do
      define :cast_vote, action: :cast_vote
      define :list_votes, action: :read
      define :get_votes_by_voter, action: :by_voter, args: [:voter_id]
      define :has_voted?, action: :read, get_by: [:voter_id, :track_id]
      define :find_vote, action: :find_vote, args: [:voter_id, :track_id]
      define :destroy_vote, action: :destroy
      define :destroy_all_votes, action: :destroy_all
    end

    resource Songbook.Music.Show do
      define :list_shows, action: :read
      define :get_show, action: :read, get_by: :id
      define :create_show, action: :create
      define :update_show, action: :update
      define :delete_show, action: :destroy
    end

    resource Songbook.Music.Playlist do
      define :list_playlists, action: :read
      define :get_playlist, action: :read, get_by: :id
      define :create_playlist, action: :create
      define :update_playlist, action: :update
      define :sync_playlist, action: :sync
      define :delete_playlist, action: :destroy
    end

    resource Songbook.Music.QuickSearch do
      define :list_quick_searches, action: :read
      define :create_quick_search, action: :create
      define :delete_quick_search, action: :destroy
    end
  end
end
