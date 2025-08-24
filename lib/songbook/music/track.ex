defmodule Songbook.Music.Track do
  @moduledoc false
  use Ash.Resource, otp_app: :songbook, domain: Songbook.Music, data_layer: AshPostgres.DataLayer

  postgres do
    table "tracks"
    repo Songbook.Repo
  end

  actions do
    defaults [:read, :create, :update, :destroy]
    default_accept [:title, :artist, :album, :album_artwork_url, :spotify_id, :votes]

    update :upvote_track do
      change increment(:votes, amount: 1)
    end

    update :downvote_track do
      change increment(:votes, amount: -1)
    end

    update :reset_votes do
      change set_attribute(:votes, 0)
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string
    attribute :artist, :string
    attribute :album, :string
    attribute :album_artwork_url, :string
    attribute :spotify_id, :string
    attribute :votes, :integer, default: 0
    timestamps(type: :utc_datetime)
  end
end
