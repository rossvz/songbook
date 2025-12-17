defmodule Songbook.Workers.UnhideTracksWorker do
  @moduledoc """
  Oban worker that checks for tracks whose hidden_until has expired
  and makes them visible again.
  Runs on a cron schedule (every 10 minutes).
  """
  use Oban.Worker, queue: :default, max_attempts: 3

  alias Songbook.Music

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    Logger.info("[UnhideTracksWorker] Checking for expired hidden tracks")

    unhidden_tracks = Music.unhide_expired_tracks()
    count = length(unhidden_tracks)

    Enum.each(unhidden_tracks, fn track ->
      Logger.info("[UnhideTracksWorker] Unhid track: #{track.title}")
      Phoenix.PubSub.broadcast(Songbook.PubSub, "votes", {:track_unhidden, track.id})
    end)

    Logger.info("[UnhideTracksWorker] Unhid #{count} tracks")
    :ok
  end
end
