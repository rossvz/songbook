defmodule SongbookWeb.Components.ThemeToggle do
  @moduledoc false
  use Phoenix.Component

  import SongbookWeb.CoreComponents, only: [icon: 1]

  @doc """
  Renders a theme toggle button that switches between light and dark mode.

  ## Examples

      <.theme_toggle />
      <.theme_toggle class="ml-4" />
  """
  attr :class, :string, default: nil
  attr :id, :string, default: "theme-toggle"

  def theme_toggle(assigns) do
    ~H"""
    <div id={@id} phx-hook=".ThemeToggle" class={["flex items-center", @class]}>
      <button
        type="button"
        class="relative inline-flex items-center justify-center w-10 h-10 rounded-xl glass transition-all duration-200 hover:scale-105 active:scale-95"
        aria-label="Toggle theme"
      >
        <.icon name="hero-sun" class="h-5 w-5 text-amber-500 dark:hidden transition-transform" />
        <.icon name="hero-moon" class="h-5 w-5 hidden dark:block text-amber-400 transition-transform" />
      </button>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".ThemeToggle">
      export default {
        mounted() {
          this.initTheme();
          this.el.addEventListener("click", (e) => {
            if (e.target.closest("button")) {
              this.toggleTheme();
            }
          });
        },

        initTheme() {
          const savedTheme = localStorage.getItem("theme");
          const html = document.documentElement;

          if (savedTheme) {
            if (savedTheme === "dark") {
              html.classList.add("dark");
            }
          } else {
            const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
            if (prefersDark) {
              html.classList.add("dark");
            }
          }

          window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", (e) => {
            if (!localStorage.getItem("theme")) {
              if (e.matches) {
                html.classList.add("dark");
              } else {
                html.classList.remove("dark");
              }
            }
          });
        },

        toggleTheme() {
          const html = document.documentElement;
          const isDark = html.classList.contains("dark");

          html.classList.add("transitioning");

          if (isDark) {
            html.classList.remove("dark");
            localStorage.setItem("theme", "light");
          } else {
            html.classList.add("dark");
            localStorage.setItem("theme", "dark");
          }

          setTimeout(() => {
            html.classList.remove("transitioning");
          }, 400);
        }
      }
    </script>
    """
  end
end
