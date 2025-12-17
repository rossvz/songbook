# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
Songbook is a Phoenix LiveView application for collaborative music voting, integrated with Spotify. Users can search for tracks via Spotify API and vote on them. The application uses Ash Framework for resource management with PostgreSQL storage.

## Development Commands

### Setup and Running
- `mix setup` - Install dependencies, setup database, build assets
- `mix phx.server` - Start Phoenix server (available at localhost:4000)
- `iex -S mix phx.server` - Start server in IEx session

### Database
- `mix ash.setup` - Setup Ash resources and database
- `mix ecto.setup` - Create, migrate and seed database
- `mix ecto.reset` - Drop and recreate database

### Testing
- `mix test` - Run all tests
- `mix test test/path/to/test.exs` - Run specific test file
- `mix test --failed` - Run only previously failed tests

### Assets and Build
- `mix assets.setup` - Install Tailwind and esbuild
- `mix assets.build` - Build assets for development
- `mix assets.deploy` - Build and minify assets for production

### Code Quality
- `mix format` - Format Elixir code
- `mix ci` - Run format check and tests (CI pipeline)

## Architecture

### Core Technologies
- **Phoenix LiveView** - Real-time web interface
- **Ash Framework** - Declarative resource management and domain modeling
- **AshPostgres** - PostgreSQL data layer for Ash
- **AshPhoenix** - Phoenix integration for Ash resources

### Domain Structure
- `Songbook.Music` - Ash domain containing Track resource
- `Songbook.Music.Track` - Main resource for music tracks with voting functionality
- `SongbookWeb.*Live` - LiveView modules for real-time UI

### Key Features
- Spotify integration for track search (`Songbook.Spotify.*`)
- Voting system with upvote/downvote/reset actions
- Real-time updates via Phoenix LiveView
- Track sorting by votes (descending) and insertion date

### Database
- Uses PostgreSQL with Ash resources
- Primary entity: `tracks` table via `Songbook.Music.Track`
- Tracks include Spotify metadata and vote counts

### Frontend
- Tailwind CSS for styling
- Phoenix LiveView for interactivity
- HeroIcons for UI icons

## Important Notes
- Extensive usage rules are defined in `AGENTS.md` covering Elixir, Phoenix, LiveView, and Ash patterns
- Follow Ash resource patterns for data access (use domain functions like `Songbook.Music.list_tracks/1`)
- Use LiveView streams for collections to avoid memory issues
- All forms should use `to_form/2` and `<.input>` components
- this app runs on port 4200 locally