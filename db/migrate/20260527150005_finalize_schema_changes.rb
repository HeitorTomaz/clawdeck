class FinalizeSchemaChanges < ActiveRecord::Migration[8.1]
  def up
    # Flip the newly-populated FKs to NOT NULL.
    change_column_null :tasks, :column_id, false
    change_column_null :api_tokens, :agent_id, false

    # Drop the legacy api_tokens.user_id FK + column.
    if foreign_key_exists?(:api_tokens, :users)
      remove_foreign_key :api_tokens, :users
    end
    remove_index :api_tokens, :user_id if index_exists?(:api_tokens, :user_id)
    remove_column :api_tokens, :user_id

    # Drop the legacy task columns replaced by column_id / assigned_agent_id.
    remove_index :tasks, :status if index_exists?(:tasks, :status)
    remove_index :tasks, :assigned_to_agent if index_exists?(:tasks, :assigned_to_agent)

    remove_column :tasks, :status
    remove_column :tasks, :assigned_to_agent
    remove_column :tasks, :assigned_at
    remove_column :tasks, :agent_claimed_at
    remove_column :tasks, :user_agent if column_exists?(:tasks, :user_agent)
  end

  def down
    # Re-add legacy columns (data loss on rollback is accepted — backfill
    # cannot be reversed cleanly since column.name is the only mapping key).
    add_column :tasks, :status, :integer, default: 0, null: false
    add_column :tasks, :assigned_to_agent, :boolean, default: false, null: false
    add_column :tasks, :assigned_at, :datetime
    add_column :tasks, :agent_claimed_at, :datetime
    add_index :tasks, :status
    add_index :tasks, :assigned_to_agent

    add_reference :api_tokens, :user, foreign_key: true, null: true
    change_column_null :tasks, :column_id, true
    change_column_null :api_tokens, :agent_id, true
  end
end
