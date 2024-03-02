defmodule SongbookWeb.SongLive.FormComponent do
  use SongbookWeb, :live_component

  alias Songbook.Tracks

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
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

      <div :if={!Enum.empty?(@results)}>
        <%= @result_index %>/<%= length(@results) %> results
      </div>

      <.simple_form
        :if={@form.data.spotify_id || @form.params["spotify_id"]}
        for={@form}
        id="song-form"
        phx-change="validate"
        phx-target={@myself}
        phx-submit="save"
      >
        <.input phx-debounce="1000" field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:artist]} type="text" label="Artist" />
        <.input field={@form[:album]} type="text" label="Album" />
        <img
          src={@form.data.album_artwork_url || @form.params["album_artwork_url"]}
          class="h-10 w-10"
        />
        <.input
          class="hidden"
          field={@form[:album_artwork_url]}
          type="text"
          label="Album artwork url"
        />
        <.input class="hidden" field={@form[:spotify_id]} type="text" label="Spotify ID" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Song</.button>
        </:actions>
      </.simple_form>
      <button phx-click="previous_result" phx-target={@myself}>Previous Result</button>
      <button phx-click="next_result" phx-target={@myself}>Next Result</button>
    </div>
    """
  end

  @impl true
  def update(%{song: song} = assigns, socket) do
    changeset = Tracks.change_song(song)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(results: [], result_index: 0)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("search", search, socket) do
    results =
      Songbook.Spotify.Search.search_song(search["title"]) |> format_results()

    socket = assign(socket, :results, results) |> next_result(0)
    {:noreply, socket}
  end

  def handle_event("next_result", _params, socket) do
    {:noreply, next_result(socket, socket.assigns.result_index + 1)}
  end

  def handle_event("previous_result", _params, socket) do
    {:noreply, next_result(socket, socket.assigns.result_index - 1)}
  end

  def handle_event("validate", %{"song" => song_params}, socket) do
    changeset =
      socket.assigns.song
      |> Tracks.change_song(song_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"song" => song_params}, socket) do
    save_song(socket, socket.assigns.action, song_params)
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

  defp next_result(socket, index) do
    spotify_data = Enum.at(socket.assigns.results, index)

    changeset =
      socket.assigns.song
      |> Tracks.change_song(spotify_data)
      |> Map.put(:action, :validate)

    assign(socket, :result_index, index) |> assign_form(changeset)
  end

  defp save_song(socket, :edit, song_params) do
    case Tracks.update_song(socket.assigns.song, song_params) do
      {:ok, song} ->
        notify_parent({:saved, song})

        {:noreply,
         socket
         |> put_flash(:info, "Song updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_song(socket, :new, song_params) do
    case Tracks.create_song(song_params) do
      {:ok, song} ->
        notify_parent({:saved, song})

        {:noreply,
         socket
         |> put_flash(:info, "Song created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket,
      form: to_form(changeset),
      search_form: to_form(%{"title" => "", "artist" => ""})
    )
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
