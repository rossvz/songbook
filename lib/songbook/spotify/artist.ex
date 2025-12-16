defmodule Songbook.Spotify.Artist do
  @moduledoc false

  alias Songbook.Spotify.Auth

  def get_artist(artist_id) do
    Req.get(
      "https://api.spotify.com/v1/artists/#{artist_id}",
      headers: [
        {"authorization", "Bearer #{Auth.get_token()}"}
      ]
    )
  end

  def get_genres(artist_id) do
    case get_artist(artist_id) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, Map.get(body, "genres", [])}

      {:ok, %{status: status}} ->
        {:error, "HTTP #{status}"}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
