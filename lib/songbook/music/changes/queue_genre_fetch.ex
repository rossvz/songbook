defmodule Songbook.Music.Changes.QueueGenreFetch do
  @moduledoc """
  An Ash change that queues the GenreFetchWorker after a track is created.
  This fetches genres from the Spotify Artist API asynchronously.
  """
  use Ash.Resource.Change

  alias Songbook.Workers.GenreFetchWorker

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn _changeset, track ->
      if track.spotify_artist_id do
        %{track_id: track.id}
        |> GenreFetchWorker.new()
        |> Oban.insert()
      end

      {:ok, track}
    end)
  end
end
