# Script for creating test shows
alias Songbook.Music

# Create test shows
{:ok, _show1} = Music.create_show(%{
  date: ~D[2025-03-15],
  time: "8:00 PM",
  venue: "The Blue Note",
  latitude: Decimal.new("40.7128"),
  longitude: Decimal.new("-74.0060")
})

{:ok, _show2} = Music.create_show(%{
  date: ~D[2025-04-20],
  time: "9:30 PM",
  venue: "Jazz Alley"
})

{:ok, _show3} = Music.create_show(%{
  date: ~D[2025-02-10],
  time: "7:00 PM",
  venue: "The Vanguard",
  latitude: Decimal.new("40.7357"),
  longitude: Decimal.new("-74.0014")
})

IO.puts("Created 3 test shows!")
