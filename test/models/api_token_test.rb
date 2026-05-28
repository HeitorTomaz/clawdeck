require "test_helper"
require "digest"

class ApiTokenTest < ActiveSupport::TestCase
  FIXTURE_RAW_TOKENS = {
    one: "test_token_one_abc123def456",
    two: "test_token_two_xyz789ghi012"
  }.freeze

  test "generates token digest on create and exposes raw_token in memory" do
    agent = agents(:one_primary)
    api_token = agent.api_tokens.create!(name: "New Token")

    assert api_token.raw_token.present?
    assert_equal 64, api_token.raw_token.length # 32 bytes hex = 64 chars
    assert api_token.token_digest.present?
    assert_equal Digest::SHA256.hexdigest(api_token.raw_token), api_token.token_digest
  end

  test "raw_token is not persisted" do
    agent = agents(:one_primary)
    api_token = agent.api_tokens.create!(name: "Ephemeral")

    reloaded = ApiToken.find(api_token.id)
    assert_nil reloaded.raw_token
    assert reloaded.token_digest.present?
  end

  test "token_digest must be unique" do
    existing_token = api_tokens(:one)
    agent = agents(:two_primary)

    new_token = agent.api_tokens.new(name: "Duplicate", token_digest: existing_token.token_digest)
    assert_not new_token.valid?
    assert_includes new_token.errors[:token_digest], "has already been taken"
  end

  test "name is required" do
    agent = agents(:one_primary)
    api_token = agent.api_tokens.new(name: nil)

    assert_not api_token.valid?
    assert_includes api_token.errors[:name], "can't be blank"
  end

  test "authenticate returns agent for valid token" do
    raw = FIXTURE_RAW_TOKENS[:one]
    agent = ApiToken.authenticate(raw)

    assert_equal api_tokens(:one).agent, agent
  end

  test "authenticate returns nil for invalid token" do
    assert_nil ApiToken.authenticate("invalid_token")
  end

  test "authenticate returns nil for blank token" do
    assert_nil ApiToken.authenticate(nil)
    assert_nil ApiToken.authenticate("")
  end

  test "authenticate updates last_used_at" do
    api_token = api_tokens(:one)
    assert_nil api_token.last_used_at

    ApiToken.authenticate(FIXTURE_RAW_TOKENS[:one])
    api_token.reload

    assert api_token.last_used_at.present?
  end

  test "belongs to agent" do
    api_token = api_tokens(:one)
    assert_equal agents(:one_primary), api_token.agent
  end

  test "delegates user to agent" do
    api_token = api_tokens(:one)
    assert_equal users(:one), api_token.user
  end
end
