defmodule SongbookWeb.SongLive.Index do
  @moduledoc false
  use SongbookWeb, :live_view

  alias Songbook.Music
  alias Songbook.Music.Track

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :songs, Music.list_tracks!())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Song")
    |> assign(:song, Music.get_track!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Song")
    |> assign(:song, %Track{})
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
end
