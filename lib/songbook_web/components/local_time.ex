defmodule SongbookWeb.Components.LocalTime do
  @moduledoc false
  use Phoenix.Component

  @doc """
  Renders a datetime in the user's local timezone.

  The server renders the ISO datetime initially, then the colocated JS hook
  formats it to the user's local timezone on mount.

  ## Examples

      <.local_time id="last-synced" datetime={@playlist.last_synced_at} />
      <.local_time id="created-at" datetime={@user.inserted_at} class="text-sm text-gray-500" />
  """
  attr :id, :string, required: true
  attr :datetime, :any, required: true
  attr :class, :string, default: nil

  def local_time(assigns) do
    ~H"""
    <span id={@id} phx-hook=".LocalTime" data-datetime={format_datetime(@datetime)} class={@class}>
      {format_datetime(@datetime)}
    </span>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".LocalTime">
      export default {
        mounted() { this.formatTime(); },
        updated() { this.formatTime(); },
        formatTime() {
          const datetime = this.el.dataset.datetime;
          if (datetime && datetime !== "Never") {
            const date = new Date(datetime);
            this.el.textContent = date.toLocaleString(undefined, {
              month: "short", day: "numeric", hour: "numeric", minute: "2-digit", hour12: true
            });
          }
        }
      }
    </script>
    """
  end

  defp format_datetime(nil), do: "Never"
  defp format_datetime(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp format_datetime(%NaiveDateTime{} = dt), do: NaiveDateTime.to_iso8601(dt)
  defp format_datetime(other), do: to_string(other)
end
