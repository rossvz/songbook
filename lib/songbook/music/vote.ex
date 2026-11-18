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

      validate fn changeset, _context ->
        track_id = Ash.Changeset.get_attribute(changeset, :track_id)

        case Songbook.Music.get_track(track_id) do
          {:ok, %{hidden: true}} ->
            {:error, field: :track_id, message: "This song is not available for voting"}

          _ ->
            :ok
        end
      end

      change after_action(&broadcast_vote_updated/3)
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

    action :destroy_all, :integer do
      run fn _input, _context ->
        result =
          Ash.bulk_destroy!(
            Songbook.Music.Vote,
            :destroy,
            %{},
            domain: Songbook.Music,
            return_records?: true
          )

        {:ok, Enum.count(result.records)}
      end

      prepare after_action(&broadcast_votes_reset/3)
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
    timestamps type: :utc_datetime
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

  defp broadcast_vote_updated(_changeset, result, _context) do
    Phoenix.PubSub.broadcast(Songbook.PubSub, "votes", {:vote_updated, result})
    {:ok, result}
  end

  defp broadcast_votes_reset(_changeset, result, _context) do
    Phoenix.PubSub.broadcast(Songbook.PubSub, "votes", :votes_reset)
    {:ok, result}
  end
end
