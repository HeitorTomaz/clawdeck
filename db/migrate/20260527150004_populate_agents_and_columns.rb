class PopulateAgentsAndColumns < ActiveRecord::Migration[8.1]
  # Mapping from the legacy Task.status enum integer to the corresponding
  # default column name. Kept here (not on Task) because Task has already
  # dropped the enum at runtime in the new model.
  LEGACY_STATUS_TO_COLUMN_NAME = {
    0 => "Inbox",
    1 => "Up Next",
    2 => "In Progress",
    3 => "In Review",
    4 => "Done"
  }.freeze

  DEFAULT_COLUMN_NAMES = [ "Inbox", "Up Next", "In Progress", "In Review", "Done" ].freeze

  # Throwaway models scoped to this migration — using the live AR classes
  # would couple us to the post-finalize schema (which no longer exposes
  # tasks.status, api_tokens.user_id, etc.).
  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"
  end

  class MigrationAgent < ActiveRecord::Base
    self.table_name = "agents"
  end

  class MigrationBoard < ActiveRecord::Base
    self.table_name = "boards"
  end

  class MigrationColumn < ActiveRecord::Base
    self.table_name = "columns"
  end

  def up
    say_with_time "Backfilling Primary agents for each user" do
      MigrationUser.find_each do |user|
        MigrationAgent.find_or_create_by!(user_id: user.id, name: "Primary") do |a|
          a.description = "Default agent created during columns migration"
        end
      end
    end

    say_with_time "Backfilling api_tokens.agent_id from user_id" do
      execute <<~SQL
        UPDATE api_tokens
        SET agent_id = (
          SELECT id FROM agents
          WHERE agents.user_id = api_tokens.user_id
            AND agents.name = 'Primary'
          LIMIT 1
        )
        WHERE agent_id IS NULL
      SQL
    end

    say_with_time "Backfilling default columns on every board" do
      MigrationBoard.find_each do |board|
        DEFAULT_COLUMN_NAMES.each_with_index do |name, idx|
          MigrationColumn.find_or_create_by!(board_id: board.id, name: name) do |col|
            col.position = idx
          end
        end
      end
    end

    say_with_time "Mapping tasks.status -> tasks.column_id" do
      LEGACY_STATUS_TO_COLUMN_NAME.each do |status_int, column_name|
        execute <<~SQL
          UPDATE tasks
          SET column_id = c.id
          FROM columns c
          WHERE c.board_id = tasks.board_id
            AND c.name = #{ActiveRecord::Base.connection.quote(column_name)}
            AND tasks.status = #{status_int}
            AND tasks.column_id IS NULL
        SQL
      end
    end

    say_with_time "Backfilling tasks.assigned_agent_id from legacy assigned_to_agent flag" do
      execute <<~SQL
        UPDATE tasks
        SET assigned_agent_id = (
          SELECT a.id FROM agents a
          WHERE a.user_id = tasks.user_id
            AND a.name = 'Primary'
          LIMIT 1
        )
        WHERE assigned_to_agent = TRUE
          AND assigned_agent_id IS NULL
      SQL
    end
  end

  def down
    # Best-effort reversal: clear the new FKs. The columns/agents tables
    # are dropped by the previous migrations on rollback.
    execute "UPDATE tasks SET column_id = NULL, assigned_agent_id = NULL"
    execute "UPDATE api_tokens SET agent_id = NULL"
    execute "DELETE FROM columns"
    execute "DELETE FROM agents"
  end
end
