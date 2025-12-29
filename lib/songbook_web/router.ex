defmodule SongbookWeb.Router do
  use SongbookWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SongbookWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SongbookWeb.Plugs.VoterSession
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug :basic_auth
    plug SongbookWeb.Plugs.AdminSession
  end

  defp basic_auth(conn, _opts) do
    username = Application.get_env(:songbook, :admin_username, "admin")
    password = Application.get_env(:songbook, :admin_password, "admin")

    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end

  # Public routes
  scope "/", SongbookWeb do
    pipe_through :browser

    live "/", VoteLive.Index, :index
    get "/search", SpotifyController, :search
    live "/vote", VoteLive.Index, :index
    live "/shows", ShowLive.Index, :index
    get "/health", HealthController, :health
    get "/up", HealthController, :up
  end

  # Admin routes - protected by BasicAuth
  scope "/admin", SongbookWeb.Admin do
    pipe_through [:browser, :admin]

    live "/songs", SongLive.Index, :index
    live "/songs/new", SongLive.Index, :new
    live "/songs/link-playlist", SongLive.Index, :link_playlist

    live "/shows", ShowLive.Index, :index
    live "/shows/new", ShowLive.Index, :new
    live "/shows/:id/edit", ShowLive.Index, :edit

    live "/quick-searches", QuickSearchLive.Index, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", SongbookWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:songbook, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SongbookWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
