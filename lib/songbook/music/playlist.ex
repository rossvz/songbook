defmodule Songbook.Music.Playlist do
  @moduledoc false
  use Ash.Resource, otp_app: :songbook, domain: Songbook.Music, data_layer: AshPostgres.DataLayer

  postgres do
    table "playlists"
    repo Songbook.Repo
  end

  actions do
    defaults [:read, :create, :destroy]
    default_accept [:spotify_playlist_id, :name, :image_url, :track_count, :external_url]

    update :update do
      accept [:spotify_playlist_id, :name, :image_url, :track_count, :external_url]
    end

    update :sync do
      require_atomic? false
      accept [:name, :image_url, :track_count]

      change fn changeset, _context ->
        Ash.Changeset.force_change_attribute(changeset, :last_synced_at, DateTime.utc_now())
      end
    end
  end

  validations do
    validate present(:spotify_playlist_id)
    validate present(:name)
  end

  attributes do
    uuid_primary_key :id
    attribute :spotify_playlist_id, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :image_url, :string
    attribute :track_count, :integer
    attribute :external_url, :string
    attribute :last_synced_at, :utc_datetime
    timestamps type: :utc_datetime
  end

  identities do
    identity :unique_spotify_playlist_id, [:spotify_playlist_id]
  end
end
