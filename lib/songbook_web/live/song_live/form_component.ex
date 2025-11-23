defmodule SongbookWeb.SongLive.FormComponent do
  @moduledoc false
  use SongbookWeb, :live_component

  alias Songbook.Music

  @impl true

  def update(assigns, socket) do
    form = to_form(%{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(results: [])
     |> assign(form: form)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="">
      <.simple_form
        :let={form}
        for={@form}
        as={:form}
        id="search-form"
        phx-target={@myself}
        phx-submit="search"
      >
        <.input
          field={form[:query]}
          type="text"
          placeholder="Search by title, artist, album"
        />
        <:actions>
          <div class="w-full flex justify-end gap-2">
            <.button
              type="button"
              class="text-zinc-700 border-2"
              phx-click={JS.patch(~p"/admin/songs")}
              phx-target={@myself}
            >
              Cancel
            </.button>
            <.button phx-disable-with="Searching..." class="bg-zinc-900 hover:bg-zinc-700">
              Search
            </.button>
          </div>
        </:actions>
      </.simple_form>

      <div :if={length(@results) > 0}>
        {length(@results)} results
      </div>

      <div id="result-list" class="flex flex-col">
        <div :for={result <- @results}>
          <.spotify_result result={result} myself={@myself} />
        </div>
      </div>
    </div>
    """
  end

  def spotify_result(assigns) do
    ~H"""
    <div
      phx-click="add_track"
      phx-value-spotify_id={@result.spotify_id}
      phx-target={@myself}
      class="flex items-center space-x-4 hover:bg-gray-100 p-2 rounded cursor-pointer"
    >
      <img src={@result.album_artwork_url} alt={@result.title} class="h-10 w-10" />
      <div>
        <h3 class="text-lg font-semibold">{@result.title}</h3>
        <p class="text-sm text-gray-500">{@result.artist} - {@result.album}</p>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("add_track", %{"spotify_id" => spotify_id}, socket) do
    result = Enum.find(socket.assigns.results, fn result -> result.spotify_id == spotify_id end)

    case Music.create_track(result) do
      {:ok, song} ->
        notify_parent({:saved, song})

        {:noreply,
         socket
         |> put_flash(:info, "Song created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, _changeset} ->
        raise "Not implemented"
    end
  end

  @impl true
  def handle_event("search", %{"form" => form}, socket) do
    query = form["query"] || ""

    results =
      if String.length(query) > 0 do
        query
        |> Songbook.Spotify.Search.search_song()
        |> format_results()
      else
        []
      end

    socket = assign(socket, :results, results)
    {:noreply, socket}
  end

  defp format_results(results) do
    Enum.map(results, fn result ->
      %{
        title: result["name"],
        spotify_id: result["id"],
        album_artwork_url: get_in(result, ["album", "images", Access.at(0), "url"]),
        album: get_in(result, ["album", "name"]),
        artist: get_in(result, ["artists", Access.at(0), "name"])
      }
    end)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
