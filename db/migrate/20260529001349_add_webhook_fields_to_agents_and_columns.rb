class AddWebhookFieldsToAgentsAndColumns < ActiveRecord::Migration[8.1]
  def change
    add_column :agents, :webhook_cron_id, :string
    add_column :columns, :webhook_enabled, :boolean, default: false, null: false
  end
end
