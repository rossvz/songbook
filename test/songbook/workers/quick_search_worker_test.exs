defmodule Songbook.Workers.QuickSearchWorkerTest do
  use Songbook.DataCase

  import Songbook.MusicFixtures

  alias Songbook.Music
  alias Songbook.Workers.QuickSearchWorker

  describe "perform/1" do
    test "generates quick searches from visible track genres and artists" do
      _t1 =
        track_with_genres_fixture(["rock", "pop"], %{
          artist: "Artist A",
          spotify_id: "spotify-1"
        })

      _t2 =
        track_with_genres_fixture(["rock"], %{
          artist: "Artist A",
          spotify_id: "spotify-2"
        })

      _t3 =
        track_with_genres_fixture(["jazz"], %{
          artist: "Artist B",
          spotify_id: "spotify-3"
        })

      assert {:ok, 5} = QuickSearchWorker.perform(%Oban.Job{})

      quick_searches =
        Music.list_quick_searches!()
        |> Map.new(fn qs -> {qs.term, qs} end)

      assert map_size(quick_searches) == 5

      assert quick_searches["rock"].source_type == :genre
      assert quick_searches["rock"].match_count == 2

      assert quick_searches["pop"].source_type == :genre
      assert quick_searches["pop"].match_count == 1

      assert quick_searches["jazz"].source_type == :genre
      assert quick_searches["jazz"].match_count == 1

      assert quick_searches["Artist A"].source_type == :artist
      assert quick_searches["Artist A"].match_count == 2

      assert quick_searches["Artist B"].source_type == :artist
      assert quick_searches["Artist B"].match_count == 1
    end

    test "ignores hidden tracks when generating quick searches" do
      visible =
        track_with_genres_fixture(["rock"], %{
          artist: "Visible Artist",
          spotify_id: "spotify-visible"
        })

      hidden =
        hidden_track_fixture(%{
          artist: "Hidden Artist",
          spotify_id: "spotify-hidden"
        })

      _hidden = Music.set_genres!(hidden, %{genres: ["secret-genre"]})

      assert {:ok, count} = QuickSearchWorker.perform(%Oban.Job{})
      assert count >= 1

      terms = Music.list_quick_searches!() |> Enum.map(& &1.term)

      assert "rock" in terms
      assert "Visible Artist" in terms

      refute "secret-genre" in terms
      refute "Hidden Artist" in terms

      # sanity check that the visible track exists and is considered visible
      assert Enum.any?(Music.list_visible_tracks!(), &(&1.id == visible.id))
    end

    test "clears existing quick searches before inserting new ones" do
      _existing =
        Music.create_quick_search!(%{
          term: "stale-term",
          source_type: :genre,
          match_count: 999
        })

      _t1 =
        track_with_genres_fixture(["fresh-genre"], %{
          artist: "Fresh Artist",
          spotify_id: "spotify-fresh"
        })

      assert {:ok, 2} = QuickSearchWorker.perform(%Oban.Job{})

      terms = Music.list_quick_searches!() |> Enum.map(& &1.term)

      refute "stale-term" in terms
      assert "fresh-genre" in terms
      assert "Fresh Artist" in terms
    end
  end
end

