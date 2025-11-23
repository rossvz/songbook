defmodule SongbookWeb.ShowLive.Admin do
  @moduledoc false
  use SongbookWeb, :live_view

  alias Songbook.Music
  alias Songbook.Music.Show

  @impl true
  def mount(_params, _session, socket) do
    shows = Music.list_shows!()

    {:ok, socket
      |> assign(:page_title, "Manage Shows")
      |> stream(:shows, shows)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info({SongbookWeb.ShowLive.FormComponent, {:saved, show}}, socket) do
    {:noreply, stream_insert(socket, :shows, show)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    show = Music.get_show!(id)
    :ok = Music.delete_show(show)

    {:noreply, stream_delete(socket, :shows, show)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Show")
    |> assign(:show, Music.get_show!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Show")
    |> assign(:show, %Show{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Manage Shows")
    |> assign(:show, nil)
  end

  def format_date(date) do
    date
    |> Calendar.strftime("%A, %B %-d, %Y")
  end
end
