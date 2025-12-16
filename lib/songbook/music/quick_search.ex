defmodule Songbook.Music.QuickSearch do
  @moduledoc false
  use Ash.Resource, otp_app: :songbook, domain: Songbook.Music, data_layer: AshPostgres.DataLayer

  postgres do
    table "quick_searches"
    repo Songbook.Repo
  end

  actions do
    defaults [:read, :create, :destroy]
    default_accept [:term, :source_type, :match_count]
  end

  attributes do
    uuid_primary_key :id
    attribute :term, :string, allow_nil?: false, public?: true

    attribute :source_type, :atom,
      constraints: [one_of: [:genre, :artist]],
      allow_nil?: false,
      public?: true

    attribute :match_count, :integer, allow_nil?: false, public?: true
    timestamps()
  end

  identities do
    identity :unique_term, [:term]
  end
end
