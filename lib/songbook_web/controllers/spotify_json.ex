defmodule SongbookWeb.SpotifyJSON do
  def index(%{items: items}) do
    %{
      items: for(item <- items, do: data(item))
    }
  end

  defp data(item) do
    item
  end
end

# SAMPLE ITEM
# %{
#   "album" => %{
#     "album_type" => "album",
#     "artists" => [
#       %{
#         "external_urls" => %{
#           "spotify" => "https://open.spotify.com/artist/4gzpq5DPGxSnKTe4SA8HAU"
#         },
#         "href" => "https://api.spotify.com/v1/artists/4gzpq5DPGxSnKTe4SA8HAU",
#         "id" => "4gzpq5DPGxSnKTe4SA8HAU",
#         "name" => "Coldplay",
#         "type" => "artist",
#         "uri" => "spotify:artist:4gzpq5DPGxSnKTe4SA8HAU"
#       }
#     ],
#     "available_markets" => ["AR", "AU", "AT", "BE", "BO", "BR", "BG", "CA",
#      "CL", "CO", "CR", "CY", "CZ", "DK", "DO", "DE", "EC", "EE", "SV", "FI",
#      "FR", "GR", "GT", "HN", "HK", "HU", "IS", "IE", "IT", "LV", "LT", "LU",
#      "MY", "MT", "MX", "NL", "NZ", "NI", "NO", "PA", "PY", "PE", "PH", "PL",
#      "PT", ...],
#     "external_urls" => %{
#       "spotify" => "https://open.spotify.com/album/6ZG5lRT77aJ3btmArcykra"
#     },
#     "href" => "https://api.spotify.com/v1/albums/6ZG5lRT77aJ3btmArcykra",
#     "id" => "6ZG5lRT77aJ3btmArcykra",
#     "images" => [
#       %{
#         "height" => 640,
#         "url" => "https://i.scdn.co/image/ab67616d0000b2733d92b2ad5af9fbc8637425f0",
#         "width" => 640
#       },
#       %{
#         "height" => 300,
#         "url" => "https://i.scdn.co/image/ab67616d00001e023d92b2ad5af9fbc8637425f0",
#         "width" => 300
#       },
#       %{
#         "height" => 64,
#         "url" => "https://i.scdn.co/image/ab67616d000048513d92b2ad5af9fbc8637425f0",
#         "width" => 64
#       }
#     ],
#     "name" => "Parachutes",
#     "release_date" => "2000-07-10",
#     "release_date_precision" => "day",
#     "total_tracks" => 10,
#     "type" => "album",
#     "uri" => "spotify:album:6ZG5lRT77aJ3btmArcykra"
#   },
#   "artists" => [
#     %{
#       "external_urls" => %{
#         "spotify" => "https://open.spotify.com/artist/4gzpq5DPGxSnKTe4SA8HAU"
#       },
#       "href" => "https://api.spotify.com/v1/artists/4gzpq5DPGxSnKTe4SA8HAU",
#       "id" => "4gzpq5DPGxSnKTe4SA8HAU",
#       "name" => "Coldplay",
#       "type" => "artist",
#       "uri" => "spotify:artist:4gzpq5DPGxSnKTe4SA8HAU"
#     }
#   ],
#   "available_markets" => ["AR", "AU", "AT", "BE", "BO", "BR", "BG", "CA",
#    "CL", "CO", "CR", "CY", "CZ", "DK", "DO", "DE", "EC", "EE", "SV", "FI",
#    "FR", "GR", "GT", "HN", "HK", "HU", "IS", "IE", "IT", "LV", "LT", "LU",
#    "MY", "MT", "MX", "NL", "NZ", "NI", "NO", "PA", "PY", "PE", "PH", "PL",
#    "PT", "SG", ...],
#   "disc_number" => 1,
#   "duration_ms" => 46200,
#   "explicit" => false,
#   "external_ids" => %{"isrc" => "GBAYE0000529"},
#   "external_urls" => %{
#     "spotify" => "https://open.spotify.com/track/4qzoHxgp42ylb18ga1SWTL"
#   },
#   "href" => "https://api.spotify.com/v1/tracks/4qzoHxgp42ylb18ga1SWTL",
#   "id" => "4qzoHxgp42ylb18ga1SWTL",
#   "is_local" => false,
#   "name" => "Parachutes",
#   "popularity" => 63,
#   "preview_url" => "https://p.scdn.co/mp3-preview/a06827d12b9282fc48ffb092f12697cf6a3a34ae?cid=4ad79359f396409eb2366ffadb10fe8b",
#   "track_number" => 7,
#   "type" => "track",
#   "uri" => "spotify:track:4qzoHxgp42ylb18ga1SWTL"
# }
