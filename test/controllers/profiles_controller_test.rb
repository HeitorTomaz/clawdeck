require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @agent = agents(:one)
    post session_path, params: { email_address: @user.email_address, password: "password123" }
  end

  test "show renders settings" do
    get settings_path
    assert_response :success
  end

  test "regenerate_api_token creates a token under the user's default agent" do
    @agent.api_tokens.destroy_all
    post regenerate_api_token_settings_path
    assert_response :success
    assert_equal 1, @agent.reload.api_tokens.count
  end

  test "regenerate_api_token accepts explicit agent_id" do
    other = @user.agents.create!(name: "Other Agent")
    post regenerate_api_token_settings_path, params: { agent_id: other.id }
    assert_response :success
    assert_equal 1, other.reload.api_tokens.count
  end

  test "regenerate_api_token rejects agent_id of another user" do
    foreign = agents(:two)
    assert_raises(ActiveRecord::RecordNotFound) do
      post regenerate_api_token_settings_path, params: { agent_id: foreign.id }
    end
  end
end
