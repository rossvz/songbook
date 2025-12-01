defmodule SongbookWeb.SongLiveTest do
  use SongbookWeb.ConnCase
  use Mimic

  import Phoenix.LiveViewTest
  import Songbook.MusicFixtures

  defp create_song(_) do
    song = track_fixture()
    %{song: song}
  end

  defp authenticate(conn) do
    credentials = Plug.BasicAuth.encode_basic_auth("admin", "admin")
    Plug.Conn.put_req_header(conn, "authorization", credentials)
  end

  describe "Index" do
    setup [:create_song]

    test "lists all songs", %{conn: conn, song: song} do
      {:ok, _index_live, html} = live(authenticate(conn), ~p"/admin/songs")

      assert html =~ "Listing Songs"
      assert html =~ song.title
    end

    test "searches for new song", %{conn: conn} do
      {:ok, index_live, _html} = live(authenticate(conn), ~p"/admin/songs")

      assert index_live |> element("a", "New Song") |> render_click() =~
               "Search by title, artist, album"

      assert_patch(index_live, ~p"/admin/songs/new")
      assert has_element?(index_live, "#search-form")

      expect(Songbook.Spotify.Search, :search_song, fn _ ->
        [
          %{
            "name" => "Result Title",
            "artists" => [%{"name" => "Result Artist"}],
            "album" => %{
              "name" => "Result Album",
              "images" => [%{"url" => "https://picsum.photos/200/300"}]
            },
            "id" => "some spotify_id"
          }
        ]
      end)

      assert index_live
             |> form("#search-form", %{
               "form" => %{"query" => "some title"}
             })
             |> render_submit()

      assert has_element?(index_live, "#result-list")

      assert index_live
             |> element("[phx-value-spotify_id='some spotify_id']")
             |> render_click()

      html = render(index_live)
      assert html =~ "Song created successfully"
      assert html =~ "Result Title"
    end

    test "deletes song in listing", %{conn: conn, song: song} do
      {:ok, index_live, _html} = live(authenticate(conn), ~p"/admin/songs")

      assert index_live
             |> element("#songs-#{song.id} button[title='Delete song']")
             |> render_click()

      refute has_element?(index_live, "#songs-#{song.id}")
    end
  end
end
