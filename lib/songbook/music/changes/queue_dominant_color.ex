defmodule Songbook.Music.Changes.QueueDominantColor do
  @moduledoc """
  An Ash change that queues the DominantColorWorker after a track is created or updated.
  This extracts the dominant color from the track's album artwork asynchronously.
  """
  use Ash.Resource.Change

  alias Songbook.Workers.DominantColorWorker

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn _changeset, track ->
      %{track_id: track.id}
      |> DominantColorWorker.new()
      |> Oban.insert()

      {:ok, track}
    end)
  end
end
