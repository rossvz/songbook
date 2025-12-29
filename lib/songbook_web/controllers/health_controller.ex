defmodule SongbookWeb.HealthController do
  use SongbookWeb, :controller

  def health(conn, _params) do
    conn
    |> put_status(:ok)
    |> text("OK")
  end

  def up(conn, _params) do
    conn
    |> put_status(:ok)
    |> text("UP")
  end
end
