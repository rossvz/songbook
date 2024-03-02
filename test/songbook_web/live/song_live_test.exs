defmodule SongbookWeb.SongLiveTest do
  use SongbookWeb.ConnCase

  import Phoenix.LiveViewTest
  import Songbook.TracksFixtures
  use Mimic

  @update_attrs %{
    title: "some updated title",
    artist: "some updated artist",
    album: "some updated album",
    album_artwork_url: "some updated album_artwork_url",
    spotify_id: "some updated spotify_id"
  }
  @invalid_attrs %{title: nil, artist: nil, album: nil, album_artwork_url: nil, spotify_id: nil}

  defp create_song(_) do
    song = song_fixture()
    %{song: song}
  end

  describe "Index" do
    setup [:create_song]

    test "lists all songs", %{conn: conn, song: song} do
      {:ok, _index_live, html} = live(conn, ~p"/songs")

      assert html =~ "Listing Songs"
      assert html =~ song.title
    end

    test "searches for new song", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/songs")

      assert index_live |> element("a", "New Song") |> render_click() =~
               "New Song"

      assert_patch(index_live, ~p"/songs/new")

      refute index_live |> has_element?("#song-form")
      assert index_live |> has_element?("#search-form")

      Songbook.Spotify.Search
      |> expect(:search_song, fn _ ->
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
               "title" => "some title",
               "artist" => "some artist"
             })
             |> render_submit()

      assert index_live |> has_element?("#song-form")

      assert index_live
             |> form("#song-form")
             |> render_submit()

      html = render(index_live)
      assert html =~ "Song created successfully"
      assert html =~ "Result Title"
    end

    test "updates song in listing", %{conn: conn, song: song} do
      {:ok, index_live, _html} = live(conn, ~p"/songs")

      assert index_live |> element("#songs-#{song.id} a", "Edit") |> render_click() =~
               "Edit Song"

      assert_patch(index_live, ~p"/songs/#{song}/edit")

      assert index_live
             |> form("#song-form", song: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#song-form", song: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/songs")

      html = render(index_live)
      assert html =~ "Song updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes song in listing", %{conn: conn, song: song} do
      {:ok, index_live, _html} = live(conn, ~p"/songs")

      assert index_live |> element("#songs-#{song.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#songs-#{song.id}")
    end
  end

  describe "Show" do
    setup [:create_song]

    test "displays song", %{conn: conn, song: song} do
      {:ok, _show_live, html} = live(conn, ~p"/songs/#{song}")

      assert html =~ "Show Song"
      assert html =~ song.title
    end

    test "updates song within modal", %{conn: conn, song: song} do
      {:ok, show_live, _html} = live(conn, ~p"/songs/#{song}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Song"

      assert_patch(show_live, ~p"/songs/#{song}/show/edit")

      assert show_live
             |> form("#song-form", song: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#song-form", song: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/songs/#{song}")

      html = render(show_live)
      assert html =~ "Song updated successfully"
      assert html =~ "some updated title"
    end
  end
end
