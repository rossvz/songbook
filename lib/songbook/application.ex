defmodule Songbook.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Songbook.Spotify.Auth

  @impl true
  def start(_type, _args) do
    children =
      [
        SongbookWeb.Telemetry,
        Songbook.Repo,
        {DNSCluster, query: Application.get_env(:songbook, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Songbook.PubSub},
        {Finch, name: Songbook.Finch},
        SongbookWeb.Endpoint
      ] ++ spotify_auth()

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

  defp spotify_auth do
    config = Application.get_env(:songbook, Songbook.Spotify)

    if config[:start_auth] do
      [Auth]
    else
      []
    end
  end
end
