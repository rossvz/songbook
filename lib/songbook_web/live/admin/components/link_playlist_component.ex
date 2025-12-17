defmodule SongbookWeb.Admin.Components.LinkPlaylistComponent do
  @moduledoc false
  use SongbookWeb, :live_component

  alias Songbook.Music
  alias Songbook.Spotify.Playlist

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(%{"url" => ""}))
     |> assign(:preview, nil)
     |> assign(:error, nil)
     |> assign(:loading, false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Link Spotify Playlist
        <:subtitle>
          Paste a Spotify playlist URL to link it to your songbook.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="link-playlist-form"
        phx-target={@myself}
        phx-submit="link"
        phx-change="validate"
      >
        <.input
          field={@form[:url]}
          type="text"
          label="Spotify Playlist URL"
          placeholder="https://open.spotify.com/playlist/..."
          phx-debounce="500"
        />

        <p :if={@error} class="text-sm text-red-600 dark:text-red-400 mt-2">
          {@error}
        </p>

        <div :if={@preview} class="mt-4 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
          <div class="flex items-center gap-4">
            <img
              :if={@preview.image_url}
              src={@preview.image_url}
              alt={@preview.name}
              class="h-16 w-16 rounded"
            />
            <div>
              <h3 class="font-medium text-gray-900 dark:text-gray-100">{@preview.name}</h3>
              <p class="text-sm text-gray-600 dark:text-gray-400">
                {@preview.track_count} tracks
              </p>
            </div>
          </div>
        </div>

        <:actions>
          <div class="w-full flex justify-end gap-2">
            <.button
              type="button"
              class="text-zinc-700 border-2"
              phx-click={JS.patch(@patch)}
            >
              Cancel
            </.button>
            <.button
              type="submit"
              disabled={@preview == nil || @loading}
              class="bg-green-600 hover:bg-green-700 disabled:opacity-50"
            >
              {if @loading, do: "Linking...", else: "Link Playlist"}
            </.button>
          </div>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"url" => url}, socket) do
    socket =
      case Playlist.parse_playlist_url(url) do
        {:ok, playlist_id} ->
          case Playlist.get_playlist(playlist_id) do
            {:ok, metadata} ->
              socket
              |> assign(:preview, metadata)
              |> assign(:error, nil)

            {:error, :not_found} ->
              socket
              |> assign(:preview, nil)
              |> assign(:error, "Playlist not found. Make sure it's public.")

            {:error, _} ->
              socket
              |> assign(:preview, nil)
              |> assign(:error, "Could not fetch playlist details.")
          end

        {:error, :invalid_url} ->
          socket
          |> assign(:preview, nil)
          |> assign(:error, if(url == "", do: nil, else: "Invalid Spotify playlist URL"))
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("link", _params, socket) do
    preview = socket.assigns.preview

    if preview do
      case Music.create_playlist(preview) do
        {:ok, playlist} ->
          notify_parent({:linked, playlist})
          {:noreply, push_patch(socket, to: socket.assigns.patch)}

        {:error, _changeset} ->
          {:noreply, assign(socket, :error, "Failed to save playlist")}
      end
    else
      {:noreply, socket}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
