# Shows Feature Implementation Tracker

## Overview
Implementing a Shows management page for Songbook with public calendar/list view and admin-only editing capabilities.

**Reference:** Based on Repertoire React app (`../repertoire/src/components/Shows/`)

---

## 🎯 Implementation Slices

### Slice 1: Backend - Ash Resource & Database
**Status:** ✅ Complete

- [x] Create `lib/songbook/music/show.ex` Ash resource
  - Fields: id, date, time, venue, latitude, longitude, timestamps
  - Validations: require date, venue
  - Preparations: sort by date ASC, filter future shows
- [x] Create database migration `priv/repo/migrations/*_add_shows.exs`
- [x] Add Show resource to `lib/songbook/music.ex` domain
  - Define CRUD actions (list_shows, get_show, create_show, update_show, delete_show)
- [x] Run migration and verify database schema
- [x] Write basic tests in `test/songbook/shows_test.exs`

**Files:**
- `lib/songbook/music/show.ex` (new)
- `lib/songbook/music.ex` (modify)
- `priv/repo/migrations/*_add_shows.exs` (new)
- `test/songbook/shows_test.exs` (new)

---

### Slice 2: Public Shows Page - Basic List View
**Status:** ✅ Complete

- [x] Create router entries in `lib/songbook_web/router.ex`
  - `live "/shows", ShowLive.Index, :index`
- [x] Create `lib/songbook_web/live/show_live/index.ex`
  - Mount: load shows using `Music.list_shows!()`
  - Stream shows to template
  - Basic page structure
- [x] Create `lib/songbook_web/live/show_live/index.html.heex`
  - Page header with title "Upcoming Shows"
  - Shows list container
  - Individual show cards with date, venue, time
- [x] Add helper functions for date formatting
- [x] Style show cards (similar to song cards)

**Files:**
- `lib/songbook_web/router.ex` (modify)
- `lib/songbook_web/live/show_live/index.ex` (new)
- `lib/songbook_web/live/show_live/index.html.heex` (new)

---

### Slice 3: Calendar Component
**Status:** ✅ Complete

- [x] Create calendar component function in `show_live/index.ex`
- [x] Implement calendar logic:
  - Calculate days in current month
  - Calculate starting day of month (offset for grid)
  - Map shows to calendar dates
  - Identify current day
- [x] Create calendar UI:
  - Month header (e.g., "March 2025")
  - Weekday labels (Su, Mo, Tu, etc.)
  - 7-column grid of dates
  - Show indicators on days with shows
  - Highlight today's date
- [x] Style calendar to match Repertoire design

**Files:**
- `lib/songbook_web/live/show_live/index.ex` (modify)
- `lib/songbook_web/live/show_live/index.html.heex` (modify)

---

### Slice 4: Google Maps Integration
**Status:** ✅ Complete

- [x] Add Google Maps API key to config
  - Not needed for basic Maps URLs (directions/search APIs)
- [x] Create helper function to generate Google Maps URLs
  - Format: `https://www.google.com/maps/dir/?api=1&destination=LAT,LNG`
  - Fallback: `https://www.google.com/maps/search/?api=1&query=VENUE_NAME`
- [x] Add Google Maps links to venue names in show cards
- [x] Test links open correctly in new tab

**Files:**
- `lib/songbook_web/live/show_live/index.ex` (modified - added `google_maps_url/1` helper)

---

### Slice 5: Admin - New Show Form (Basic)
**Status:** ✅ Complete

- [x] Add route: `live "/shows/new", ShowLive.Index, :new`
- [x] Create `lib/songbook_web/live/show_live/form_component.ex`
- [x] Implement modal form component
  - Date input (type="date")
  - Venue input (text - basic, no autocomplete yet)
  - Time input (type="text" with placeholder)
  - Cancel/Save buttons
- [x] Handle form submission
  - Validate inputs via AshPhoenix.Form
  - Create show via form submission
  - Close modal and refresh list via stream_insert
- [x] Add "New Show" button (visible in header)
- [x] Style form to match app design

**Files:**
- `lib/songbook_web/router.ex` (modified - added `:new` route)
- `lib/songbook_web/live/show_live/form_component.ex` (new - complete form with AshPhoenix integration)
- `lib/songbook_web/live/show_live/index.ex` (modified - added `apply_action` and `handle_info` for form)
- `lib/songbook_web/live/show_live/index.html.heex` (modified - added "New Show" button and modal)

---

### Slice 6: Admin - Google Places Autocomplete
**Status:** ✅ Complete

- [x] Create `assets/js/hooks/places_autocomplete.js`
- [x] Implement Phoenix Hook for Google Places API
  - Initialize autocomplete on venue input
  - Restrict to establishments
  - Handle place selection
  - Extract lat/lng via Geocoding API
  - Push data to LiveView
- [x] Register hook in `assets/js/app.js`
- [x] Update form component to use hook
  - Add `phx-hook="PlacesAutocomplete"` to venue input
  - Receive lat/lng from hook via `handle_event("place_selected")`
  - Include coordinates in form submission with hidden fields
- [x] Load Google Maps JavaScript API in layout
- [x] Add Google Maps API key configuration to runtime.exs
- [x] Test autocomplete functionality (requires API key to fully test)

**Files:**
- `assets/js/hooks/places_autocomplete.js` (new - complete hook implementation)
- `assets/js/app.js` (modified - imported and registered hook)
- `lib/songbook_web/live/show_live/form_component.ex` (modified - added hook, hidden fields, event handler)
- `lib/songbook_web/components/layouts/root.html.heex` (modified - added Google Maps script)
- `lib/songbook_web/components/layouts/app.html.heex` (modified - added Shows nav link)
- `config/runtime.exs` (modified - added google_maps_api_key config)

**Notes:**
- ✅ Requires `GOOGLE_MAPS_API_KEY` environment variable - WORKING with valid key
- ⚠️ Google deprecated old Places Autocomplete API (March 2025) - may need migration to new Places API (New) in future
- ✅ Manual venue entry works without API key
- ✅ Autocomplete FULLY FUNCTIONAL - captures venue name, latitude, and longitude
- ✅ Tested with multiple venues - location data successfully pushed to FormComponent

**Setup Required:**
1. Set `GOOGLE_MAPS_API_KEY` in environment (.envrc)
2. Add localhost:4000 to Google API Console approved referrers
3. Restart Phoenix server with `source .envrc && mix phx.server`

---

### Slice 7: Admin - Edit & Delete Shows
**Status:** ⬜ Not Started

- [ ] Add route: `live "/shows/:id/edit", ShowLive.Index, :edit`
- [ ] Update `apply_action/3` in index.ex to handle `:edit`
- [ ] Modify form component to support edit mode
  - Pre-populate form with existing show data
  - Update heading (New Show vs Edit Show)
  - Save updates via `Music.update_show/2`
- [ ] Add delete button to show cards (admin-only)
- [ ] Implement delete event handler
  - Confirm deletion (optional)
  - Delete via `Music.delete_show/1`
  - Remove from stream
- [ ] Add edit button to show cards (admin-only)

**Files:**
- `lib/songbook_web/router.ex` (modify)
- `lib/songbook_web/live/show_live/index.ex` (modify)
- `lib/songbook_web/live/show_live/form_component.ex` (modify)

---

### Slice 8: Authentication & Authorization
**Status:** ⬜ Not Started

- [ ] Determine auth approach:
  - Option A: Use existing voter session with admin flag
  - Option B: Implement BasicAuth for admin routes
  - Option C: Add simple password check in LiveView
- [ ] Implement chosen auth approach
- [ ] Protect admin actions (create/edit/delete)
- [ ] Show/hide admin UI based on auth status
- [ ] Test unauthorized access is blocked

**Files:**
- TBD based on auth approach chosen

---

### Slice 9: Polish & Testing
**Status:** ⬜ Not Started

- [ ] Add loading states for async operations
- [ ] Add error handling and user feedback
- [ ] Test date filtering (only future shows)
- [ ] Test calendar with shows on various dates
- [ ] Test form validation
- [ ] Test edit/delete functionality
- [ ] Responsive design testing
- [ ] Cross-browser testing
- [ ] Add fixtures for test data
- [ ] Write comprehensive tests

**Files:**
- Various files for polish
- `test/songbook_web/live/show_live_test.exs` (new)
- `test/support/fixtures/shows_fixtures.ex` (new)

---

## 🔧 Dependencies & Setup

### External Services
- Google Maps JavaScript API (Places Library)
- Google Maps Geocoding API

### Environment Variables
```bash
GOOGLE_MAPS_API_KEY=your_api_key_here
```

### Hex Packages
- No additional packages needed (using core Phoenix/Ash)

---

## 📝 Notes

- Following Ash Framework patterns (similar to Track resource)
- Using LiveView streams for efficient list updates
- Calendar shows current month only
- Shows filtered to display only future dates
- Google Maps integration matches Repertoire functionality
- Admin controls hidden from public users

---

## ✅ Progress Tracker

- [x] Slice 1: Backend - Ash Resource & Database
- [x] Slice 2: Public Shows Page - Basic List View
- [x] Slice 3: Calendar Component
- [x] Slice 4: Google Maps Integration
- [x] Slice 5: Admin - New Show Form (Basic)
- [x] Slice 6: Admin - Google Places Autocomplete
- [ ] Slice 7: Admin - Edit & Delete Shows
- [ ] Slice 8: Authentication & Authorization
- [ ] Slice 9: Polish & Testing

**Overall Progress:** 6/9 slices complete
