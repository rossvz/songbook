defmodule Songbook.Spotify.Search do
  @moduledoc false
  def query(q, type) do
    q = URI.encode_www_form(q)

    Req.get(
      "https://api.spotify.com/v1/search?q=#{q}&type=#{type}",
      headers: [
        {"authorization", "Bearer #{Songbook.Spotify.Auth.get_token()}"}
      ]
    )
  end

  def search_song(q) do
    q
    |> query("track")
    |> parse("tracks")
  end

  def search_artist(q) do
    query(q, "artist")
  end

  def search_album(q) do
    query(q, "album")
  end

  ######

  defp parse({:ok, %{body: body}}, type) do
    body
    |> Map.get(type)
    |> Map.get("items")
  end

  defp parse({:error, error}, _type) do
    raise "Failed to search: #{inspect(error)}"
  end
end
