defmodule Songbook.Workers.GenreFetchWorker do
  @moduledoc """
  Oban worker that fetches genres from Spotify's Artist API.
  Genres are associated with artists in Spotify, not tracks, so we fetch
  the artist details and extract the genres array.
  """
  use Oban.Worker, queue: :default, max_attempts: 3

  alias Songbook.Music
  alias Songbook.Spotify.Artist

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"track_id" => track_id}}) do
    case Music.get_track(track_id) do
      {:ok, track} ->
        fetch_and_save_genres(track)

      {:error, _} ->
        Logger.warning("[GenreFetchWorker] Track #{track_id} not found")
        :ok
    end
  end

  defp fetch_and_save_genres(%{spotify_artist_id: nil}), do: :ok
  defp fetch_and_save_genres(%{genres: genres}) when genres != [], do: :ok

  defp fetch_and_save_genres(track) do
    Logger.info("[GenreFetchWorker] Fetching genres for track: #{track.title}")

    with {:ok, genres} <- Artist.get_genres(track.spotify_artist_id),
         {:ok, _updated_track} <- Music.set_genres(track, %{genres: genres}) do
      Logger.info("[GenreFetchWorker] Set genres #{inspect(genres)} for track: #{track.title}")
      :ok
    else
      {:error, error} ->
        Logger.warning("[GenreFetchWorker] Failed to fetch/save genres for #{track.title}: #{inspect(error)}")

        :ok
    end
  end
end
