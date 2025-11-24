defmodule SongbookWeb.PageControllerTest do
  use SongbookWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Vote for Songs"
  end
end
