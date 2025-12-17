defmodule SongbookWeb.Plugs.AdminSession do
  @moduledoc """
  Plug to set admin session flag after successful BasicAuth authentication.
  This allows the public voting page to detect admin users.
  """
  import Plug.Conn

  @session_key "is_admin"

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_session(@session_key, true)
    |> configure_session(renew: true)
  end
end
