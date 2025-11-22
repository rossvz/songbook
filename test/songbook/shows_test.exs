defmodule Songbook.ShowsTest do
  use Songbook.DataCase

  import Songbook.MusicFixtures
  import Ash.Test

  alias Songbook.Music

  describe "shows" do
    alias Songbook.Music.Show

    @invalid_attrs %{date: nil, venue: nil}

    test "list_shows/0 returns all shows" do
      show = show_fixture()
      assert_stripped Music.list_shows!() == [show]
    end

    test "list_shows/0 returns shows sorted by date ascending" do
      show1 = show_fixture(%{date: ~D[2025-03-15]})
      show2 = show_fixture(%{date: ~D[2025-01-10]})
      show3 = show_fixture(%{date: ~D[2025-02-20]})

      assert_stripped Music.list_shows!() == [show2, show3, show1]
    end

    test "get_show!/1 returns the show with given id" do
      show = show_fixture()
      assert_stripped Music.get_show!(show.id) == show
    end

    test "create_show/1 with valid data creates a show" do
      valid_attrs = %{
        date: ~D[2025-12-31],
        time: "9:00 PM",
        venue: "The Jazz Club",
        latitude: Decimal.new("40.7128"),
        longitude: Decimal.new("-74.0060")
      }

      assert {:ok, %Show{} = show} = Music.create_show(valid_attrs)
      assert show.date == ~D[2025-12-31]
      assert show.time == "9:00 PM"
      assert show.venue == "The Jazz Club"
      assert show.latitude == Decimal.new("40.7128")
      assert show.longitude == Decimal.new("-74.0060")
    end

    test "create_show/1 with minimal valid data creates a show" do
      valid_attrs = %{
        date: ~D[2025-12-31],
        venue: "The Jazz Club"
      }

      assert {:ok, %Show{} = show} = Music.create_show(valid_attrs)
      assert show.date == ~D[2025-12-31]
      assert show.venue == "The Jazz Club"
      assert show.time == nil
      assert show.latitude == nil
      assert show.longitude == nil
    end

    test "create_show/1 with invalid data returns error changeset" do
      assert {:error, %Ash.Error.Invalid{}} = Music.create_show(@invalid_attrs)
    end

    test "update_show/2 with valid data updates the show" do
      show = show_fixture()
      update_attrs = %{venue: "Updated Venue", time: "10:00 PM"}

      assert {:ok, %Show{} = updated_show} = Music.update_show(show, update_attrs)
      assert updated_show.venue == "Updated Venue"
      assert updated_show.time == "10:00 PM"
    end

    test "delete_show/1 deletes the show" do
      show = show_fixture()
      assert Music.delete_show(show) == :ok
      assert_raise Ash.Error.Invalid, fn -> Music.get_show!(show.id) end
    end

    test "is_future calculation returns true for future shows" do
      future_show = show_fixture(%{date: Date.add(Date.utc_today(), 10)})
      loaded_show = Music.get_show!(future_show.id, load: [:is_future])
      assert loaded_show.is_future == true
    end

    test "is_future calculation returns false for past shows" do
      past_show = show_fixture(%{date: Date.add(Date.utc_today(), -10)})
      loaded_show = Music.get_show!(past_show.id, load: [:is_future])
      assert loaded_show.is_future == false
    end
  end
end
