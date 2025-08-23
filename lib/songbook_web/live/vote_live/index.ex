defmodule SongbookWeb.VoteLive.Index do
  @moduledoc false
  use SongbookWeb, :live_view

  alias Songbook.Tracks

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Songbook.PubSub, "votes")

    {:ok, stream(socket, :songs, Tracks.list_songs())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, :page_title, "Vote for Songs")
  end

  @impl true
  def handle_event("vote", %{"id" => id}, socket) do
    song = Tracks.get_song!(id)

    case Tracks.upvote_song(song) do
      {:ok, updated_song} ->
        # Broadcast to all connected users
        Phoenix.PubSub.broadcast(Songbook.PubSub, "votes", {:vote_updated, updated_song})

        # Reload the entire sorted list
        {:noreply, stream(socket, :songs, Tracks.list_songs(), reset: true)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Unable to process vote")}
    end
  end

  @impl true
  def handle_info({:vote_updated, _song}, socket) do
    # Reload the entire sorted list for all connected clients
    {:noreply, stream(socket, :songs, Tracks.list_songs(), reset: true)}
  end

  @impl true
  def handle_info(:votes_reset, socket) do
    # Reload the entire sorted list when votes are reset
    {:noreply, stream(socket, :songs, Tracks.list_songs(), reset: true)}
  end
end
