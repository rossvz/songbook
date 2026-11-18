defmodule Songbook.Music.Show do
  @moduledoc """
  Represents a musical performance or show event.
  """
  use Ash.Resource, otp_app: :songbook, domain: Songbook.Music, data_layer: AshPostgres.DataLayer

  postgres do
    table "shows"
    repo Songbook.Repo
  end

  actions do
    defaults [:read, :create, :update, :destroy]
    default_accept [:date, :time, :venue, :latitude, :longitude]
  end

  preparations do
    prepare build(sort: [date: :asc])
  end

  validations do
    validate present(:date)
    validate present(:venue)
  end

  attributes do
    uuid_primary_key :id
    attribute :date, :date, allow_nil?: false
    attribute :time, :string
    attribute :venue, :string, allow_nil?: false
    attribute :latitude, :decimal
    attribute :longitude, :decimal
    timestamps type: :utc_datetime
  end

  calculations do
    calculate :is_future, :boolean, expr(date >= today())
  end
end
