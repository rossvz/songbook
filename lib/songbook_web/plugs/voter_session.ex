defmodule SongbookWeb.Plugs.VoterSession do
  @moduledoc """
  Plug to manage anonymous voter sessions using signed cookies.
  """
  import Plug.Conn

  @cookie_name "voter_id"

  def init(opts), do: opts

  def call(conn, _opts) do
    {conn, voter_id} = get_or_create_voter_id(conn)

    assign(conn, :voter_id, voter_id)
  end

  defp get_or_create_voter_id(conn) do
    case get_session(conn, @cookie_name) do
      nil ->
        voter_id = generate_voter_id()

        updated_conn =
          conn
          |> put_session(@cookie_name, voter_id)
          |> configure_session(renew: true)

        {updated_conn, voter_id}

      voter_id when is_binary(voter_id) ->
        {conn, voter_id}
    end
  end

  defp generate_voter_id do
    Ash.UUID.generate()
  end
end
