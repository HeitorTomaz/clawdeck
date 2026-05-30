class RenameWebhookCronIdToWebhookAgentId < ActiveRecord::Migration[8.1]
  def change
    rename_column :agents, :webhook_cron_id, :webhook_agent_id
  end
end
