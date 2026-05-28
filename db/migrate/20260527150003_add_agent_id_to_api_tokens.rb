class AddAgentIdToApiTokens < ActiveRecord::Migration[8.1]
  def change
    # Nullable temporarily — backfill assigns each existing token to its
    # owner's "Primary" agent before the finalize migration flips it NOT NULL
    # and drops user_id.
    add_reference :api_tokens, :agent, null: true, foreign_key: true
  end
end
