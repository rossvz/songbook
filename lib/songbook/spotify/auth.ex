defmodule Songbook.Spotify.Auth do
  @moduledoc false
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> token() end,
      name: __MODULE__
    )
  end

  def get_token do
    now = DateTime.to_unix(DateTime.utc_now())

    case Agent.get(__MODULE__, & &1) do
      %{expires_at: expires_at, token: token} when expires_at > now ->
        token

      _ ->
        refresh_token()
    end
  end

  def put_token(token_data) do
    Agent.update(__MODULE__, fn _ ->
      token_data
    end)

    token_data
  end

  defp refresh_token, do: token() |> put_token() |> Map.get(:token)

  def authenticate do
    Req.post(
      url: "https://accounts.spotify.com/api/token",
      form: %{
        grant_type: "client_credentials",
        client_id: Application.get_env(:songbook, Songbook.Spotify)[:client_id],
        client_secret: Application.get_env(:songbook, Songbook.Spotify)[:secret_key]
      },
      headers: [
        {"content-type", "application/x-www-form-urlencoded"}
      ]
    )
  end

  def token do
    case authenticate() do
      {:ok, %{body: %{"access_token" => token}}} ->
        %{
          token: token,
          expires_at: in_one_hour()
        }

      {:error, error} ->
        raise "Failed to authenticate with Spotify: #{inspect(error)}"
    end
  end

  defp in_one_hour, do: DateTime.utc_now() |> DateTime.shift(hour: 1) |> DateTime.to_unix()
end
