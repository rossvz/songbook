defmodule Songbook.Spotify.Playlist do
  @moduledoc false

  def get_playlist(playlist_id) do
    url =
      "https://api.spotify.com/v1/playlists/#{playlist_id}?fields=id,name,external_urls,images,tracks.total"

    case Req.get(url, headers: auth_headers()) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, parse_playlist(body)}

      {:ok, %{status: 404}} ->
        {:error, :not_found}

      {:ok, %{status: status, body: body}} ->
        {:error, {:api_error, status, body}}

      {:error, error} ->
        {:error, error}
    end
  end

  def parse_playlist_url(url_or_id) when is_binary(url_or_id) do
    cond do
      String.contains?(url_or_id, "open.spotify.com/playlist/") ->
        url_or_id
        |> String.split("playlist/")
        |> List.last()
        |> String.split("?")
        |> List.first()
        |> then(&{:ok, &1})

      String.starts_with?(url_or_id, "spotify:playlist:") ->
        {:ok, String.replace(url_or_id, "spotify:playlist:", "")}

      String.match?(url_or_id, ~r/^[a-zA-Z0-9]{22}$/) ->
        {:ok, url_or_id}

      true ->
        {:error, :invalid_url}
    end
  end

  def parse_playlist_url(_), do: {:error, :invalid_url}

  defp parse_playlist(body) do
    %{
      spotify_playlist_id: body["id"],
      name: body["name"],
      external_url: get_in(body, ["external_urls", "spotify"]),
      image_url: get_in(body, ["images", Access.at(0), "url"]),
      track_count: get_in(body, ["tracks", "total"])
    }
  end

  defp auth_headers do
    [{"authorization", "Bearer #{Songbook.Spotify.Auth.get_token()}"}]
  end
end
