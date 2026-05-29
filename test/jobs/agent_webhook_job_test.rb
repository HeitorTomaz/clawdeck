require "test_helper"
require "minitest/mock"

class AgentWebhookJobTest < ActiveJob::TestCase
  setup do
    @task = tasks(:one)
    @agent = agents(:one_primary)
    @agent.update!(webhook_cron_id: "11111111-2222-3333-4444-555555555555")
    @column = columns(:one_inbox)
    @column.update!(assigned_agent: @agent, webhook_enabled: true)
  end

  test "calls dispatcher when conditions are met" do
    fake = Minitest::Mock.new
    fake.expect :call, :ok
    AgentWebhookDispatcher.stub(:new, ->(task, agent) {
      assert_equal @task.id, task.id
      assert_equal @agent.id, agent.id
      fake
    }) do
      AgentWebhookJob.new.perform(@task.id, @column.id)
    end
    fake.verify
  end

  test "no-ops when column webhook_enabled is false" do
    @column.update!(webhook_enabled: false)
    AgentWebhookDispatcher.stub(:new, ->(*) { raise "should not be called" }) do
      assert_nothing_raised { AgentWebhookJob.new.perform(@task.id, @column.id) }
    end
  end

  test "no-ops when column has no assigned agent" do
    @column.update!(assigned_agent: nil)
    AgentWebhookDispatcher.stub(:new, ->(*) { raise "should not be called" }) do
      assert_nothing_raised { AgentWebhookJob.new.perform(@task.id, @column.id) }
    end
  end

  test "no-ops when assigned agent has no webhook_cron_id" do
    @agent.update!(webhook_cron_id: nil)
    AgentWebhookDispatcher.stub(:new, ->(*) { raise "should not be called" }) do
      assert_nothing_raised { AgentWebhookJob.new.perform(@task.id, @column.id) }
    end
  end

  test "no-ops when task is missing" do
    AgentWebhookDispatcher.stub(:new, ->(*) { raise "should not be called" }) do
      assert_nothing_raised { AgentWebhookJob.new.perform(-1, @column.id) }
    end
  end
end
