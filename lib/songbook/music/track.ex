defmodule Songbook.Music.Track do
  @moduledoc false
  use Ash.Resource, otp_app: :songbook, domain: Songbook.Music, data_layer: AshPostgres.DataLayer

  postgres do
    table "tracks"
    repo Songbook.Repo
  end

  actions do
    defaults [:read, :create, :update, :destroy]
    default_accept [:title, :artist, :album, :album_artwork_url, :spotify_id]

    update :reset_votes do
      require_atomic? false

      change after_action(fn _changeset, result, _context ->
        # Delete all votes for this track by loading them first
        track_with_votes = Songbook.Music.get_track!(result.id, load: [:track_votes])

        track_with_votes.track_votes
        |> Enum.each(fn vote ->
          vote
          |> Ash.Changeset.for_destroy(:destroy)
          |> Songbook.Music.destroy!()
        end)

        {:ok, result}
      end)
    end
  end

  preparations do
    prepare build(sort: [vote_count: :desc, inserted_at: :desc], load: [:vote_count])
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
    timestamps(type: :utc_datetime)
  end

  aggregates do
    count :vote_count, :track_votes
  end

  relationships do
    has_many :track_votes, Songbook.Music.Vote do
      source_attribute :id
      destination_attribute :track_id
    end
  end
end
