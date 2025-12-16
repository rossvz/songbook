defmodule Songbook.Music.Track do
  @moduledoc false
  use Ash.Resource, otp_app: :songbook, domain: Songbook.Music, data_layer: AshPostgres.DataLayer

  postgres do
    table "tracks"
    repo Songbook.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    default_accept [
      :title,
      :artist,
      :album,
      :album_artwork_url,
      :spotify_id,
      :spotify_artist_id,
      :hidden
    ]

    create :create do
      accept [
        :title,
        :artist,
        :album,
        :album_artwork_url,
        :spotify_id,
        :spotify_artist_id,
        :hidden
      ]

      change Songbook.Music.Changes.QueueDominantColor
      change Songbook.Music.Changes.QueueGenreFetch
    end

    read :list_visible do
      filter expr(hidden != true)
    end

    update :toggle_visibility do
      accept []
      require_atomic? false

      change fn changeset, _context ->
        current_hidden = changeset.data.hidden == true
        Ash.Changeset.force_change_attribute(changeset, :hidden, not current_hidden)
      end
    end

    update :reset_votes do
      require_atomic? false

      change after_action(fn _changeset, result, _context ->
               # Delete all votes for this track by loading them first
               track_with_votes = Songbook.Music.get_track!(result.id, load: [:track_votes])

               Enum.each(track_with_votes.track_votes, fn vote ->
                 vote
                 |> Ash.Changeset.for_destroy(:destroy)
                 |> Songbook.Music.destroy!()
               end)

               {:ok, result}
             end)
    end

    update :set_dominant_color do
      accept [:dominant_color]
    end

    update :set_genres do
      accept [:genres]
    end
  end

  preparations do
    prepare build(
              sort: [hidden: :asc, vote_count: :desc, inserted_at: :desc],
              load: [:vote_count]
            )
  end

  validations do
    validate present(:title)
    validate present(:artist)
    validate present(:album)
    validate present(:album_artwork_url)
    validate present(:spotify_id)
  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string
    attribute :artist, :string
    attribute :album, :string
    attribute :album_artwork_url, :string
    attribute :spotify_id, :string
    attribute :spotify_artist_id, :string
    attribute :hidden, :boolean, default: false
    attribute :dominant_color, :string
    attribute :genres, {:array, :string}, default: []
    timestamps(type: :utc_datetime)
  end

  relationships do
    has_many :track_votes, Songbook.Music.Vote do
      source_attribute :id
      destination_attribute :track_id
    end
  end

  aggregates do
    count :vote_count, :track_votes
  end
end
