defmodule SongbookWeb.ShowLive.Index do
  @moduledoc false
  use SongbookWeb, :live_view

  alias Songbook.Music
  alias Songbook.Music.Show

  @impl true
  def mount(_params, _session, socket) do
    shows = get_future_shows()
    calendar_data = build_calendar(shows, nil)

    {:ok,
     socket
     |> assign(:has_shows, not Enum.empty?(shows))
     |> assign(:selected_date, nil)
     |> assign(:calendar_data, calendar_data)
     |> stream(:shows, shows)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, :page_title, "Upcoming Shows")
  end

  @impl true
  def handle_event("select_date", %{"date" => date_string}, socket) do
    selected_date = Date.from_iso8601!(date_string)
    all_shows = get_future_shows()

    filtered_shows =
      Enum.filter(all_shows, fn show ->
        Date.compare(show.date, selected_date) == :eq
      end)

    calendar_data = build_calendar(all_shows, selected_date)

    {:noreply,
     socket
     |> assign(:selected_date, selected_date)
     |> assign(:calendar_data, calendar_data)
     |> stream(:shows, filtered_shows, reset: true)}
  end

  def handle_event("clear_date_filter", _params, socket) do
    all_shows = get_future_shows()
    calendar_data = build_calendar(all_shows, nil)

    {:noreply,
     socket
     |> assign(:selected_date, nil)
     |> assign(:calendar_data, calendar_data)
     |> stream(:shows, all_shows, reset: true)}
  end

  def format_date(date) do
    Calendar.strftime(date, "%A, %B %-d")
  end

  def google_maps_url(%Show{latitude: lat, longitude: lng}) when not is_nil(lat) and not is_nil(lng) do
    "https://www.google.com/maps/dir/?api=1&destination=#{lat},#{lng}"
  end

  def google_maps_url(%Show{venue: venue}) do
    "https://www.google.com/maps/search/?api=1&query=#{URI.encode(venue)}"
  end

  defp get_future_shows do
    # Get today's date in Eastern timezone
    eastern_now = DateTime.now!("America/New_York")
    today = DateTime.to_date(eastern_now)

    # Get all shows and filter for future dates
    Enum.filter(Music.list_shows!(), fn show -> Date.compare(show.date, today) != :lt end)
  end

  defp build_calendar(shows, selected_date) do
    # Use Eastern timezone for everything
    eastern_now = DateTime.now!("America/New_York")
    today = DateTime.to_date(eastern_now)
    current_month = Date.beginning_of_month(today)
    days_in_month = Date.days_in_month(current_month)

    # Get day of week for first day (1 = Monday, 7 = Sunday)
    # We want Sunday = 0, so we convert: Sunday (7) -> 0, Monday (1) -> 1, etc.
    first_day_of_week =
      case Date.day_of_week(current_month) do
        # Sunday
        7 -> 0
        # Monday = 1, Tuesday = 2, ..., Saturday = 6
        day -> day
      end

    # Create map of show dates for quick lookup
    show_dates = MapSet.new(shows, fn show -> show.date end)

    # Create empty days for offset (cells before the 1st of the month)
    empty_days =
      if first_day_of_week > 0 do
        Enum.map(1..first_day_of_week, fn _ -> %{empty: true} end)
      else
        []
      end

    # Create days for the month
    month_days =
      Enum.map(1..days_in_month, fn day ->
        date = Date.new!(current_month.year, current_month.month, day)

        %{
          date: day,
          full_date: Date.to_iso8601(date),
          has_show: MapSet.member?(show_dates, date),
          is_today: Date.compare(date, today) == :eq,
          is_selected: selected_date && Date.compare(date, selected_date) == :eq
        }
      end)

    %{
      month_name: Calendar.strftime(current_month, "%B %Y"),
      days: empty_days ++ month_days
    }
  end
end
