defmodule SongbookWeb.SongLive.FormComponent do
  @moduledoc false
  use SongbookWeb, :live_component

  alias Songbook.Tracks

  @impl true

  def update(%{song: song} = assigns, socket) do
    changeset = Tracks.change_song(song)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(results: [])
     |> assign_form(changeset)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="">
      <.header>
        {@title}
        <:subtitle>Use this form to manage song records in your database.</:subtitle>
      </.header>

      <.simple_form
        :if={@action == :new}
        for={@search_form}
        id="search-form"
        phx-target={@myself}
        phx-submit="search"
      >
        <.input field={@search_form[:title]} type="text" label="Title" />
        <.input field={@search_form[:artist]} type="text" label="Artist" />
        <:actions>
          <.button phx-disable-with="Searching...">Search</.button>
        </:actions>
      </.simple_form>

      <div :if={@results}>
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

    case Tracks.create_song(result) do
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
  def handle_event("search", %{"search" => search}, socket) do
    title = search["title"] || ""
    artist = search["artist"] || ""

    query = String.trim("#{title} #{artist}")

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

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    search_params = %{"title" => "", "artist" => ""}

    assign(socket,
      form: to_form(changeset),
      search_form: to_form(search_params, as: :search)
    )
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
