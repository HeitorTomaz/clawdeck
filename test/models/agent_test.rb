require "test_helper"

class AgentTest < ActiveSupport::TestCase
  test "valid with a name and user" do
    agent = Agent.new(user: users(:one), name: "Brand new agent")
    assert agent.valid?
  end

  test "requires a name" do
    agent = Agent.new(user: users(:one), name: nil)
    assert_not agent.valid?
    assert_includes agent.errors[:name], "can't be blank"
  end

  test "requires a user" do
    agent = Agent.new(user: nil, name: "Orphan")
    assert_not agent.valid?
    assert_includes agent.errors[:user], "must exist"
  end

  test "name must be unique within the same user" do
    duplicate = Agent.new(user: users(:one), name: agents(:one_primary).name)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "same name allowed across different users" do
    cross = Agent.new(user: users(:two), name: agents(:one_primary).name)
    assert cross.valid?, cross.errors.full_messages.to_sentence
  end

  test "destroying an agent nullifies tasks_assigned and columns_assigned" do
    agent = agents(:one_primary)
    task = tasks(:one)
    task.update!(assigned_agent: agent)

    column = columns(:one_inbox)
    column.update!(assigned_agent: agent)

    agent.destroy!
    assert_nil task.reload.assigned_agent_id
    assert_nil column.reload.assigned_agent_id
  end

  test "destroying an agent destroys its api_tokens" do
    agent = agents(:one_primary)
    token_id = api_tokens(:one).id
    agent.destroy!
    assert_nil ApiToken.find_by(id: token_id)
  end
end
