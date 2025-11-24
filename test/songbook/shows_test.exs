defmodule Songbook.ShowsTest do
  use Songbook.DataCase

  import Ash.Test
  import Songbook.MusicFixtures

  alias Ash.Error.Invalid
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
      assert {:error, %Invalid{}} = Music.create_show(@invalid_attrs)
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
      assert_raise Invalid, fn -> Music.get_show!(show.id) end
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

    test "create_show/1 allows past dates" do
      past_date = ~D[2020-01-01]
      valid_attrs = %{date: past_date, venue: "Historic Venue"}

      assert {:ok, %Show{} = show} = Music.create_show(valid_attrs)
      assert show.date == past_date
    end

    test "create_show/1 requires date field" do
      invalid_attrs = %{venue: "Some Venue"}
      assert {:error, %Invalid{}} = Music.create_show(invalid_attrs)
    end

    test "create_show/1 requires venue field" do
      invalid_attrs = %{date: ~D[2025-12-31]}
      assert {:error, %Invalid{}} = Music.create_show(invalid_attrs)
    end

    test "allows multiple shows at the same venue" do
      venue = "The Blue Note"
      show1 = show_fixture(%{venue: venue, date: ~D[2025-01-15]})
      show2 = show_fixture(%{venue: venue, date: ~D[2025-02-20]})

      assert show1.venue == venue
      assert show2.venue == venue
      assert show1.id != show2.id
    end

    test "allows multiple shows on the same date" do
      date = ~D[2025-12-31]
      show1 = show_fixture(%{date: date, venue: "Venue A"})
      show2 = show_fixture(%{date: date, venue: "Venue B"})

      assert show1.date == date
      assert show2.date == date
      assert show1.id != show2.id
    end

    test "update_show/2 can update date" do
      show = show_fixture()
      new_date = ~D[2026-06-15]
      update_attrs = %{date: new_date}

      assert {:ok, %Show{} = updated_show} = Music.update_show(show, update_attrs)
      assert updated_show.date == new_date
    end

    test "update_show/2 can update optional time field" do
      show = show_fixture(%{time: "9:00 PM"})
      update_attrs = %{time: "10:00 PM"}

      assert {:ok, %Show{} = updated_show} = Music.update_show(show, update_attrs)
      assert updated_show.time == "10:00 PM"
    end

    test "update_show/2 preserves unchanged fields" do
      show = show_fixture(%{venue: "Original Venue", time: "8:00 PM"})
      update_attrs = %{time: "9:00 PM"}

      assert {:ok, %Show{} = updated_show} = Music.update_show(show, update_attrs)
      assert updated_show.venue == "Original Venue"
      assert updated_show.time == "9:00 PM"
    end

    test "coordinates stored as Decimal types" do
      lat = Decimal.new("40.7580")
      lng = Decimal.new("-73.9855")
      show = show_fixture(%{latitude: lat, longitude: lng})

      assert show.latitude == lat
      assert show.longitude == lng
      assert is_struct(show.latitude, Decimal)
      assert is_struct(show.longitude, Decimal)
    end
  end
end
