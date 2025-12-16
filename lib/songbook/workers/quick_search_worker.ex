defmodule Songbook.Workers.QuickSearchWorker do
  @moduledoc """
  Oban worker that generates quick search suggestions from track genres and artists.
  Runs on a cron schedule (every 30 minutes).
  """
  use Oban.Worker, queue: :default, max_attempts: 3

  alias Songbook.Music

  require Logger

  @target_count 12

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    regenerate_quick_searches()
  end

  def regenerate_quick_searches do
    Logger.info("[QuickSearchWorker] Starting quick search generation")

    tracks = Music.list_visible_tracks!()

    genre_counts = count_genres(tracks)
    artist_counts = count_artists(tracks)

    valid_genres = sort_by_count(genre_counts, :genre)
    valid_artists = sort_by_count(artist_counts, :artist)

    selected = select_terms(valid_genres, valid_artists, @target_count)

    clear_existing_quick_searches()
    insert_quick_searches(selected)

    Logger.info("[QuickSearchWorker] Generated #{length(selected)} quick searches")
    {:ok, length(selected)}
  end

  defp count_genres(tracks) do
    tracks
    |> Enum.flat_map(fn track -> track.genres || [] end)
    |> Enum.frequencies()
  end

  defp count_artists(tracks) do
    tracks
    |> Enum.map(& &1.artist)
    |> Enum.reject(&is_nil/1)
    |> Enum.frequencies()
  end

  defp sort_by_count(counts, source_type) do
    counts
    |> Enum.map(fn {term, count} -> %{term: term, count: count, source_type: source_type} end)
    |> Enum.sort_by(& &1.count, :desc)
  end

  defp select_terms(genres, artists, target) do
    genres
    |> interleave(artists)
    |> Enum.take(target)
  end

  defp interleave(list1, list2) do
    list1
    |> do_interleave(list2, [])
    |> Enum.reverse()
  end

  defp do_interleave([], [], acc), do: acc
  defp do_interleave([], rest, acc), do: Enum.reverse(rest, acc)
  defp do_interleave(rest, [], acc), do: Enum.reverse(rest, acc)
  defp do_interleave([h1 | t1], [h2 | t2], acc), do: do_interleave(t1, t2, [h2, h1 | acc])

  defp clear_existing_quick_searches do
    Enum.each(Music.list_quick_searches!(), &Music.delete_quick_search!/1)
  end

  defp insert_quick_searches(terms) do
    Enum.each(terms, fn %{term: term, count: count, source_type: source_type} ->
      Music.create_quick_search!(%{
        term: term,
        source_type: source_type,
        match_count: count
      })
    end)
  end
end
