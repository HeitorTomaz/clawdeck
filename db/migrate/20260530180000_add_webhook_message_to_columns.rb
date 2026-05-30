class AddWebhookMessageToColumns < ActiveRecord::Migration[8.1]
  def change
    add_column :columns, :webhook_message, :text
  end
end
