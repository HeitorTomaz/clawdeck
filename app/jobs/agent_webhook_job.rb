class AgentWebhookJob < ApplicationJob
  queue_as :default

  retry_on Net::OpenTimeout, Net::ReadTimeout, AgentWebhookDispatcher::TransientError,
           wait: :polynomially_longer, attempts: 5

  def perform(task_id, column_id)
    task = Task.find_by(id: task_id)
    column = Column.find_by(id: column_id)
    return unless task && column
    return unless column.webhook_enabled?
    return unless column.assigned_agent&.webhook_cron_id.present?

    AgentWebhookDispatcher.new(task, column.assigned_agent).call
  end
end
