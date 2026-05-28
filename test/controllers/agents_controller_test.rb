require "test_helper"

class AgentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @agent = agents(:one)
    post session_path, params: { email_address: @user.email_address, password: "password123" }
  end

  test "index lists current user's agents" do
    get agents_path
    assert_response :success
  end

  test "create adds an agent" do
    assert_difference "Agent.count", 1 do
      post agents_path, params: { agent: { name: "Researcher", description: "Reads things" } }
    end
    assert_redirected_to agent_path(Agent.last)
  end

  test "create rejects duplicate name for same user" do
    assert_no_difference "Agent.count" do
      post agents_path, params: { agent: { name: @agent.name } }
    end
  end

  test "update edits the agent" do
    patch agent_path(@agent), params: { agent: { description: "Updated desc" } }
    assert_equal "Updated desc", @agent.reload.description
  end

  test "show displays the agent and its tokens" do
    get agent_path(@agent)
    assert_response :success
  end

  test "destroy deletes the agent" do
    other = current_user_agents.create!(name: "Disposable")
    assert_difference "Agent.count", -1 do
      delete agent_path(other)
    end
    assert_redirected_to agents_path
  end

  test "cannot access another user's agent" do
    other_agent = agents(:two)
    assert_raises(ActiveRecord::RecordNotFound) do
      get agent_path(other_agent)
    end
  end

  private

  def current_user_agents
    @user.agents
  end
end
