defmodule Songbook.Workers.DominantColorWorker do
  @moduledoc """
  Oban worker that extracts the dominant color from a track's album artwork.
  Uses the Image library to analyze the image and stores the hex color on the track.
  """
  use Oban.Worker, queue: :default, max_attempts: 3

  alias Songbook.Music

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"track_id" => track_id}}) do
    case Music.get_track(track_id) do
      {:ok, track} ->
        extract_and_save_color(track)

      {:error, _} ->
        Logger.warning("[DominantColorWorker] Track #{track_id} not found")
        :ok
    end
  end

  defp extract_and_save_color(%{album_artwork_url: nil}), do: :ok
  defp extract_and_save_color(%{dominant_color: color}) when is_binary(color), do: :ok

  defp extract_and_save_color(track) do
    Logger.info("[DominantColorWorker] Extracting color for track: #{track.title}")

    with {:ok, image} <- fetch_image(track.album_artwork_url),
         {:ok, [r, g, b | _]} <- Image.dominant_color(image) do
      hex_color = rgb_to_hex(round(r), round(g), round(b))

      case Music.set_dominant_color(track, %{dominant_color: hex_color}) do
        {:ok, _updated_track} ->
          Logger.info("[DominantColorWorker] Set color #{hex_color} for track: #{track.title}")
          :ok

        {:error, error} ->
          Logger.error("[DominantColorWorker] Failed to save color: #{inspect(error)}")
          {:error, error}
      end
    else
      {:error, reason} ->
        Logger.warning("[DominantColorWorker] Failed to extract color for #{track.title}: #{inspect(reason)}")
        :ok
    end
  end

  defp fetch_image(url) do
    case Req.get(url) do
      {:ok, %{status: 200, body: body}} ->
        Image.from_binary(body)

      {:ok, %{status: status}} ->
        {:error, "HTTP #{status}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp rgb_to_hex(r, g, b) do
    "#" <>
      (r |> Integer.to_string(16) |> String.pad_leading(2, "0")) <>
      (g |> Integer.to_string(16) |> String.pad_leading(2, "0")) <>
      (b |> Integer.to_string(16) |> String.pad_leading(2, "0"))
  end
end
