defmodule Songbook.Music.Vote do
  @moduledoc false
  use Ash.Resource, otp_app: :songbook, domain: Songbook.Music, data_layer: AshPostgres.DataLayer

  postgres do
    table "votes"
    repo Songbook.Repo
  end

  actions do
    defaults [:read, :create, :destroy]
    default_accept [:voter_id, :track_id]

    create :cast_vote do
      accept [:voter_id, :track_id]
    end

    read :by_voter do
      argument :voter_id, :string, allow_nil?: false

      filter expr(voter_id == ^arg(:voter_id))
    end

    read :find_vote do
      argument :voter_id, :string, allow_nil?: false
      argument :track_id, :uuid, allow_nil?: false
      get? true

      filter expr(voter_id == ^arg(:voter_id) and track_id == ^arg(:track_id))
    end
  end

  validations do
    validate present(:voter_id)
    validate present(:track_id)
  end

  attributes do
    uuid_primary_key :id
    attribute :voter_id, :string, allow_nil?: false
    attribute :track_id, :uuid, allow_nil?: false
    timestamps(type: :utc_datetime)
  end

  relationships do
    belongs_to :track, Songbook.Music.Track do
      source_attribute :track_id
      destination_attribute :id
    end
  end

  identities do
    identity :unique_vote, [:voter_id, :track_id]
  end
end
