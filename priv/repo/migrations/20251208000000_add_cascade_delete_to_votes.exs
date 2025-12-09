defmodule Songbook.Repo.Migrations.AddCascadeDeleteToVotes do
  use Ecto.Migration

  def up do
    # Drop the existing foreign key constraint
    drop constraint(:votes, "votes_track_id_fkey")

    # Add the new foreign key constraint with ON DELETE CASCADE
    alter table(:votes) do
      modify :track_id,
             references(:tracks,
               column: :id,
               name: "votes_track_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             ),
             null: false
    end
  end

  def down do
    # Drop the cascade constraint
    drop constraint(:votes, "votes_track_id_fkey")

    # Restore the original foreign key constraint without cascade
    alter table(:votes) do
      modify :track_id,
             references(:tracks,
               column: :id,
               name: "votes_track_id_fkey",
               type: :uuid,
               prefix: "public"
             ),
             null: false
    end
  end
end
