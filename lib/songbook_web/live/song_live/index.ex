defmodule SongbookWeb.SongLive.Index do
  @moduledoc false
  use SongbookWeb, :live_view

  alias Songbook.Music
  alias Songbook.Music.Track
  alias Songbook.Workers.PlaylistSyncWorker

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Songbook.PubSub, "tracks")
    end

    {:ok,
     socket
     |> assign(:playlist, get_linked_playlist())
     |> stream(:songs, Music.list_tracks!())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Song")
    |> assign(:song, %Track{})
  end

  defp apply_action(socket, :link_playlist, _params) do
    socket
    |> assign(:page_title, "Link Spotify Playlist")
    |> assign(:song, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Songs")
    |> assign(:song, nil)
  end

  defp get_linked_playlist do
    case Music.list_playlists!() do
      [playlist | _] -> playlist
      [] -> nil
    end
  end

  @impl true
  def handle_info({SongbookWeb.SongLive.FormComponent, {:saved, song}}, socket) do
    {:noreply, stream_insert(socket, :songs, song)}
  end

  @impl true
  def handle_info({SongbookWeb.SongLive.LinkPlaylistComponent, {:linked, playlist}}, socket) do
    {:noreply,
     socket
     |> assign(:playlist, playlist)
     |> put_flash(:info, "Playlist linked successfully")}
  end

  @impl true
  def handle_info({:track_created, track}, socket) do
    track = Ash.load!(track, [:vote_count])
    {:noreply, stream_insert(socket, :songs, track, at: 0)}
  end

  @impl true
  def handle_event("toggle_visibility", %{"id" => id}, socket) do
    song = Music.get_track!(id)

    case Music.toggle_visibility(song) do
      {:ok, _updated_song} ->
        {:noreply, stream(socket, :songs, Music.list_tracks!(), reset: true)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Unable to toggle visibility")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    song = Music.get_track!(id)

    case Music.delete_track(song) do
      :ok ->
        {:noreply, stream_delete(socket, :songs, song)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Unable to delete song")}
    end
  end

  @impl true
  def handle_event("reset_votes", _params, socket) do
    Enum.each(Music.list_tracks!(), fn track ->
      Music.reset_votes(track)
    end)

    # Broadcast vote reset to all connected voting clients
    Phoenix.PubSub.broadcast(Songbook.PubSub, "votes", :votes_reset)

    # Reload the songs list to show updated vote counts
    {:noreply,
     socket
     |> put_flash(:info, "All votes have been reset to 0")
     |> stream(:songs, Music.list_tracks!(), reset: true)}
  end

  @impl true
  def handle_event("sync_playlist", _params, socket) do
    # Queue an Oban job for full track sync
    %{}
    |> PlaylistSyncWorker.new()
    |> Oban.insert()

    {:noreply, put_flash(socket, :info, "Playlist sync started. New tracks will be added shortly.")}
  end

  @impl true
  def handle_event("unlink_playlist", _params, socket) do
    if socket.assigns.playlist do
      Music.delete_playlist!(socket.assigns.playlist)
    end

    {:noreply,
     socket
     |> assign(:playlist, nil)
     |> put_flash(:info, "Playlist unlinked")}
  end

  def format_sync_time(nil), do: "Never"
  def format_sync_time(datetime), do: DateTime.to_iso8601(datetime)
end
