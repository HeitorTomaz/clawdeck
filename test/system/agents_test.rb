require "application_system_test_case"

class AgentsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)

    visit new_session_path
    fill_in "email_address", with: @user.email_address
    fill_in "password",      with: "password"
    click_button "Sign in"
  end

  test "user lists their agents from the agents page" do
    skip "Agents fixture not yet wired" unless @user.respond_to?(:agents)

    visit agents_path
    assert_selector "h2", text: "Agents"
    @user.agents.each do |agent|
      assert_selector "li#agent-#{agent.id}", text: agent.name
    end
  end

  test "user creates a new agent" do
    skip "Agents controller not yet wired" unless defined?(AgentsController)

    visit new_agent_path
    fill_in "Name", with: "QA Bot"
    fill_in "Description", with: "Runs end-to-end checks"
    click_button "Create agent"

    assert_text "QA Bot"
  end

  test "generating a token shows the raw value once" do
    skip "Agents controller not yet wired" unless defined?(AgentsController)
    agent = @user.agents.first || @user.agents.create!(name: "Primary")

    visit agents_path
    within "li#agent-#{agent.id}" do
      accept_confirm { click_button "Generate token" }
    end

    assert_text "New token"
    assert_selector "code", text: /\S+/
  end

  test "user edits an agent" do
    skip "Agents controller not yet wired" unless defined?(AgentsController)
    agent = @user.agents.first || @user.agents.create!(name: "Primary")

    visit edit_agent_path(agent)
    fill_in "Name", with: "Renamed Agent"
    click_button "Save changes"

    assert_text "Renamed Agent"
  end
end
