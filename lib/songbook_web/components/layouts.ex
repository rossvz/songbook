defmodule SongbookWeb.Layouts do
  @moduledoc false
  use SongbookWeb, :html

  import SongbookWeb.Components.ThemeToggle

  embed_templates "layouts/*"
end
