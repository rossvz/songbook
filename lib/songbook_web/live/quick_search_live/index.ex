defmodule SongbookWeb.QuickSearchLive.Index do
  @moduledoc false
  use SongbookWeb, :live_view

  alias Songbook.Music
  alias Songbook.Workers.QuickSearchWorker

  @impl true
  def mount(_params, _session, socket) do
    quick_searches = Music.list_quick_searches!()

    {:ok,
     socket
     |> assign(:page_title, "Quick Searches")
     |> stream(:quick_searches, quick_searches)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    quick_searches = Music.list_quick_searches!()
    quick_search = Enum.find(quick_searches, &(&1.id == id))

    if quick_search do
      :ok = Music.delete_quick_search(quick_search)
      {:noreply, stream_delete(socket, :quick_searches, quick_search)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("regenerate", _params, socket) do
    %{}
    |> QuickSearchWorker.new()
    |> Oban.insert()

    Process.send_after(self(), :reload_quick_searches, 1000)

    {:noreply, put_flash(socket, :info, "Regenerating quick searches...")}
  end

  @impl true
  def handle_info(:reload_quick_searches, socket) do
    quick_searches = Music.list_quick_searches!()

    {:noreply,
     socket
     |> stream(:quick_searches, quick_searches, reset: true)
     |> put_flash(:info, "Quick searches regenerated")}
  end

  def format_source_type(:genre), do: "Genre"
  def format_source_type(:artist), do: "Artist"
  def format_source_type(_), do: "Unknown"
end
