defmodule SongbookWeb.SongLive.Show do
  @moduledoc false
  use SongbookWeb, :live_view

  alias Songbook.Music

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    track = Music.get_track!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:track, track)}
  end

  defp page_title(:show), do: "Show Song"
  defp page_title(:edit), do: "Edit Song"
end
