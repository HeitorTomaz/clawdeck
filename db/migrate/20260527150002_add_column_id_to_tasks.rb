class AddColumnIdToTasks < ActiveRecord::Migration[8.1]
  def change
    # Nullable temporarily — the backfill migration populates these before
    # the finalize migration flips column_id to NOT NULL.
    add_reference :tasks, :column, null: true, foreign_key: true
    add_reference :tasks, :assigned_agent, null: true, foreign_key: { to_table: :agents }
  end
end
