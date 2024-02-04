defmodule SongbookWeb.SpotifyController do
  use SongbookWeb, :controller
  alias Songbook.Spotify.Search

  def search(conn, %{"q" => q}) do
    items = Search.search_song(q)
    render(conn, "index.json", items: items)
  end
end
