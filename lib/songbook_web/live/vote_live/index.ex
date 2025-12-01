defmodule SongbookWeb.VoteLive.Index do
  @moduledoc false
  use SongbookWeb, :live_view

  alias Songbook.Music

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Songbook.PubSub, "votes")

    # Get voter_id from session (set by our plug)
    voter_id = session["voter_id"]

    socket =
      socket
      |> assign(:voter_id, voter_id)
      |> assign(:voted_tracks, get_voted_tracks(voter_id))
      |> assign(:playlist, get_linked_playlist())
      |> assign(:player_visible, true)
      |> stream(:songs, Music.list_visible_tracks!())

    {:ok, socket}
  end

  defp get_linked_playlist do
    case Music.list_playlists!() do
      [playlist | _] -> playlist
      [] -> nil
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, :page_title, "Vote for Songs")
  end

  @impl true
  def handle_event("toggle_player", _params, socket) do
    {:noreply, assign(socket, :player_visible, !socket.assigns.player_visible)}
  end

  @impl true
  def handle_event("vote", %{"id" => id}, socket) do
    voter_id = socket.assigns.voter_id
    voted_tracks = socket.assigns.voted_tracks

    cond do
      # Check if we have a voter_id
      is_nil(voter_id) or voter_id == "" ->
        {:noreply, put_flash(socket, :error, "Unable to identify voter")}

      # Check if user has already voted for this track
      MapSet.member?(voted_tracks, id) ->
        {:noreply, put_flash(socket, :error, "You have already voted for this track")}

      true ->
        song = Music.get_track!(id)

        if song.hidden do
          {:noreply, put_flash(socket, :error, "This song is not available for voting")}
        else
          # Create the vote record
          case Music.cast_vote(%{voter_id: voter_id, track_id: id}) do
            {:ok, _vote} ->
              # Update local state
              updated_voted_tracks = MapSet.put(voted_tracks, id)

              socket =
                socket
                |> assign(:voted_tracks, updated_voted_tracks)
                |> stream(:songs, Music.list_visible_tracks!(), reset: true)

              # Broadcast to all connected users
              Phoenix.PubSub.broadcast(Songbook.PubSub, "votes", {:vote_updated, song})

              {:noreply, socket}

            {:error, changeset} ->
              dbg(changeset)
              {:noreply, put_flash(socket, :error, "Unable to record vote")}
          end
        end
    end
  end

  @impl true
  def handle_info({:vote_updated, _song}, socket) do
    # Reload the entire sorted list for all connected clients
    {:noreply, stream(socket, :songs, Music.list_visible_tracks!(), reset: true)}
  end

  @impl true
  def handle_info(:votes_reset, socket) do
    # Reload the entire sorted list when votes are reset
    # Also reload the voted_tracks for this user since they should now be able to vote again
    voter_id = socket.assigns.voter_id

    socket =
      socket
      |> assign(:voted_tracks, get_voted_tracks(voter_id))
      |> stream(:songs, Music.list_visible_tracks!(), reset: true)

    {:noreply, socket}
  end

  defp get_voted_tracks(voter_id) when is_binary(voter_id) do
    voter_id
    |> Music.get_votes_by_voter()
    |> case do
      {:ok, votes} -> votes
      {:error, _reason} -> []
    end
    |> MapSet.new(& &1.track_id)
  end

  defp get_voted_tracks(_), do: MapSet.new()
end
