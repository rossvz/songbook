defmodule Songbook.Tracks do
  @moduledoc """
  The Tracks context.
  """

  import Ecto.Query, warn: false

  alias Songbook.Repo
  alias Songbook.Tracks.Song

  @doc """
  Returns the list of songs ordered by votes descending.

  ## Examples

      iex> list_songs()
      [%Song{}, ...]

  """
  def list_songs do
    Repo.all(from s in Song, order_by: [desc: s.votes, asc: s.inserted_at])
  end

  @doc """
  Gets a single song.

  Raises `Ecto.NoResultsError` if the Song does not exist.

  ## Examples

      iex> get_song!(123)
      %Song{}

      iex> get_song!(456)
      ** (Ecto.NoResultsError)

  """
  def get_song!(id), do: Repo.get!(Song, id)

  @doc """
  Creates a song.

  ## Examples

      iex> create_song(%{field: value})
      {:ok, %Song{}}

      iex> create_song(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_song(attrs \\ %{}) do
    %Song{}
    |> Song.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a song.

  ## Examples

      iex> update_song(song, %{field: new_value})
      {:ok, %Song{}}

      iex> update_song(song, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_song(%Song{} = song, attrs) do
    song
    |> Song.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a song.

  ## Examples

      iex> delete_song(song)
      {:ok, %Song{}}

      iex> delete_song(song)
      {:error, %Ecto.Changeset{}}

  """
  def delete_song(%Song{} = song) do
    Repo.delete(song)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking song changes.

  ## Examples

      iex> change_song(song)
      %Ecto.Changeset{data: %Song{}}

  """
  def change_song(%Song{} = song, attrs \\ %{}) do
    Song.changeset(song, attrs)
  end

  @doc """
  Increments the vote count for a song.

  ## Examples

      iex> upvote_song(song)
      {:ok, %Song{}}

  """
  def upvote_song(%Song{} = song) do
    song
    |> Ecto.Changeset.change(votes: song.votes + 1)
    |> Repo.update()
  end

  @doc """
  Decrements the vote count for a song.

  ## Examples

      iex> downvote_song(song)
      {:ok, %Song{}}

  """
  def downvote_song(%Song{} = song) do
    new_votes = max(0, song.votes - 1)

    song
    |> Ecto.Changeset.change(votes: new_votes)
    |> Repo.update()
  end

  @doc """
  Resets all songs' votes to 0.

  ## Examples

      iex> reset_all_votes()
      {5, nil}

  """
  def reset_all_votes do
    Repo.update_all(from(s in Song, update: [set: [votes: 0]]), [])
  end
end
