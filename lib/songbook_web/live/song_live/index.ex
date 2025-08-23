defmodule SongbookWeb.SongLive.Index do
  @moduledoc false
  use SongbookWeb, :live_view

  alias Songbook.Tracks
  alias Songbook.Tracks.Song

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :songs, Tracks.list_songs())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Song")
    |> assign(:song, Tracks.get_song!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Song")
    |> assign(:song, %Song{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Songs")
    |> assign(:song, nil)
  end

  @impl true
  def handle_info({SongbookWeb.SongLive.FormComponent, {:saved, song}}, socket) do
    {:noreply, stream_insert(socket, :songs, song)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    song = Tracks.get_song!(id)
    {:ok, _} = Tracks.delete_song(song)

    {:noreply, stream_delete(socket, :songs, song)}
  end

  @impl true
  def handle_event("reset_votes", _params, socket) do
    {_count, _} = Tracks.reset_all_votes()

    # Broadcast vote reset to all connected voting clients
    Phoenix.PubSub.broadcast(Songbook.PubSub, "votes", :votes_reset)

    # Reload the songs list to show updated vote counts
    {:noreply,
     socket
     |> put_flash(:info, "All votes have been reset to 0")
     |> stream(:songs, Tracks.list_songs(), reset: true)}
  end
end
