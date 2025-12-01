defmodule Songbook.Workers.PlaylistSyncWorker do
  @moduledoc """
  Oban worker that syncs tracks from a linked Spotify playlist to the database.
  Runs on a cron schedule (every 30 minutes by default).
  Only adds new tracks - does not delete existing tracks.
  """
  use Oban.Worker, queue: :playlist_sync, max_attempts: 3

  alias Songbook.Music
  alias Songbook.Spotify.Playlist, as: SpotifyPlaylist

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    case get_linked_playlist() do
      nil ->
        Logger.info("[PlaylistSyncWorker] No playlist linked, skipping sync")
        :ok

      playlist ->
        sync_playlist(playlist)
    end
  end

  defp get_linked_playlist do
    case Music.list_playlists!() do
      [playlist | _] -> playlist
      [] -> nil
    end
  end

  defp sync_playlist(playlist) do
    Logger.info("[PlaylistSyncWorker] Starting sync for playlist: #{playlist.name}")

    with {:ok, spotify_tracks} <-
           SpotifyPlaylist.get_playlist_tracks(playlist.spotify_playlist_id),
         {:ok, metadata} <- SpotifyPlaylist.get_playlist(playlist.spotify_playlist_id) do
      existing_spotify_ids = get_existing_spotify_ids()
      new_tracks = filter_new_tracks(spotify_tracks, existing_spotify_ids)

      {added_count, errors} = add_new_tracks(new_tracks)

      # Update playlist metadata and last_synced_at (only pass accepted fields)
      sync_attrs = Map.take(metadata, [:name, :image_url, :track_count])
      Music.sync_playlist!(playlist, sync_attrs)

      Logger.info("[PlaylistSyncWorker] Sync complete. Added #{added_count} new tracks. Errors: #{length(errors)}")

      if errors == [] do
        :ok
      else
        {:error, "Some tracks failed to sync: #{inspect(errors)}"}
      end
    else
      {:error, reason} ->
        Logger.error("[PlaylistSyncWorker] Failed to fetch playlist: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp get_existing_spotify_ids do
    MapSet.new(Music.list_tracks!(), & &1.spotify_id)
  end

  defp filter_new_tracks(spotify_tracks, existing_ids) do
    Enum.reject(spotify_tracks, fn track ->
      MapSet.member?(existing_ids, track.spotify_id)
    end)
  end

  defp add_new_tracks(tracks) do
    Enum.reduce(tracks, {0, []}, fn track, {count, errors} ->
      case Music.create_track(track) do
        {:ok, created_track} ->
          Phoenix.PubSub.broadcast(Songbook.PubSub, "tracks", {:track_created, created_track})
          {count + 1, errors}

        {:error, error} ->
          Logger.warning("[PlaylistSyncWorker] Failed to add track #{track.title}: #{inspect(error)}")

          {count, [{track.spotify_id, error} | errors]}
      end
    end)
  end
end
