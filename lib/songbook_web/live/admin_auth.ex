defmodule SongbookWeb.AdminAuth do
  @moduledoc """
  LiveView on_mount hook to enforce admin authentication.

  This ensures admin routes are protected during LiveView navigation,
  not just on initial HTTP requests.
  """
  use SongbookWeb, :verified_routes

  def on_mount(:default, _params, session, socket) do
    if session["is_admin"] == true do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    end
  end
end
