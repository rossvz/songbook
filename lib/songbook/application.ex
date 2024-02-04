defmodule Songbook.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SongbookWeb.Telemetry,
      Songbook.Repo,
      {DNSCluster, query: Application.get_env(:songbook, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Songbook.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Songbook.Finch},
      Songbook.Spotify.Auth,
      # Start a worker by calling: Songbook.Worker.start_link(arg)
      # {Songbook.Worker, arg},
      # Start to serve requests, typically the last entry
      SongbookWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Songbook.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SongbookWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
