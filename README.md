# Songbook

Local development and tests use an existing PostgreSQL server on `localhost:5432`.
They use separate databases, `songbook_dev` and `songbook_test`.

## Development setup

1. Run `mise trust` and `mise install` in the worktree to use the Elixir and
   Erlang versions pinned in `mise.toml`.
2. In the 1Password desktop app, add `SPOTIFY_CLIENT_ID` and
   `SPOTIFY_SECRET_KEY` to an Environment. Connect it as a **Local .env file**
   at `~/.local/share/envs/songbook.env`. All Songbook worktrees can use this
   shared mount. If you chose another location, set `SONGBOOK_ENV_FILE` to its
   absolute path before running mise.
3. Use mise activation in your interactive shell or put the mise shims on
   `PATH` for non-interactive shells and agents. Approve the 1Password prompt
   on the first read. Later reads reuse that approval until 1Password locks.

From the worktree, run the usual commands:

  * Run `mix setup` to install dependencies and set up the workspace.
  * Run `mix ecto.migrate` when you need to apply database migrations.
  * Start Phoenix with `mix phx.server` or `iex -S mix phx.server`.

Now you can visit [`localhost:4200`](http://localhost:4200) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
