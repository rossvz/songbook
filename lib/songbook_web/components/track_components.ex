defmodule SongbookWeb.TrackComponents do
  @moduledoc """
  Track-specific UI components for displaying song information, album artwork, and voting.
  """
  use Phoenix.Component

  import SongbookWeb.CoreComponents, only: [icon: 1]

  attr :song, :map, required: true
  attr :adaptive, :boolean, default: false
  attr :class, :string, default: nil

  def song_info(assigns) do
    ~H"""
    <div class={["flex-1 min-w-0", @class]}>
      <h3 class={[
        "font-display text-lg sm:text-xl font-semibold truncate",
        @adaptive && "adaptive-title",
        !@adaptive && "text-primary"
      ]}>
        {@song.title}
      </h3>
      <p class={[
        "text-base sm:text-lg font-medium mt-0.5 truncate",
        @adaptive && "adaptive-artist",
        !@adaptive && "text-secondary"
      ]}>
        {@song.artist}
      </p>
      <p class={[
        "text-sm font-medium mt-0.5 truncate",
        @adaptive && "adaptive-album",
        !@adaptive && "text-tertiary"
      ]}>
        {@song.album}
      </p>
    </div>
    """
  end

  attr :count, :integer, required: true
  attr :size, :string, default: "default", values: ["default", "large"]
  attr :class, :string, default: nil

  def vote_count(assigns) do
    ~H"""
    <div class={["text-center", @class]}>
      <span class={[
        "font-bold text-primary block",
        @size == "large" && "text-xl",
        @size == "default" && "text-lg"
      ]}>
        {@count}
      </span>
      <span class="text-xs text-tertiary">
        {if @count == 1, do: "vote", else: "votes"}
      </span>
    </div>
    """
  end

  attr :url, :string, default: nil
  attr :alt, :string, required: true
  attr :size, :string, default: "default", values: ["default", "large", "small"]
  attr :class, :string, default: nil

  def album_artwork(assigns) do
    ~H"""
    <%= if @url do %>
      <img
        src={@url}
        alt={@alt}
        class={[
          "album-art object-cover flex-shrink-0",
          @size == "large" && "h-20 w-20 sm:h-24 sm:w-24",
          @size == "default" && "w-16 h-16 sm:w-20 sm:h-20",
          @size == "small" && "w-12 h-12",
          @class
        ]}
      />
    <% else %>
      <div class={[
        "rounded-xl bg-accent-soft flex items-center justify-center flex-shrink-0",
        @size == "large" && "h-20 w-20 sm:h-24 sm:w-24",
        @size == "default" && "w-16 h-16 sm:w-20 sm:h-20",
        @size == "small" && "w-12 h-12",
        @class
      ]}>
        <.icon
          name="hero-musical-note"
          class={
            "text-accent " <>
            cond do
              @size == "large" -> "w-10 h-10"
              @size == "small" -> "w-6 h-6"
              true -> "w-8 h-8"
            end
          }
        />
      </div>
    <% end %>
    """
  end
end
