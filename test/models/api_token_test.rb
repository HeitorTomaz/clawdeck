require "test_helper"
require "digest"

class ApiTokenTest < ActiveSupport::TestCase
  FIXTURE_RAW_TOKENS = {
    one: "test_token_one_abc123def456",
    two: "test_token_two_xyz789ghi012"
  }.freeze

  test "generates token digest on create and exposes raw_token in memory" do
    user = users(:one)
    api_token = user.api_tokens.create!(name: "New Token")

    assert api_token.raw_token.present?
    assert_equal 64, api_token.raw_token.length # 32 bytes hex = 64 chars
    assert api_token.token_digest.present?
    assert_equal Digest::SHA256.hexdigest(api_token.raw_token), api_token.token_digest
  end

  test "raw_token is not persisted" do
    user = users(:one)
    api_token = user.api_tokens.create!(name: "Ephemeral")

    reloaded = ApiToken.find(api_token.id)
    assert_nil reloaded.raw_token
    assert reloaded.token_digest.present?
  end

  test "token_digest must be unique" do
    existing_token = api_tokens(:one)
    user = users(:two)

    new_token = user.api_tokens.new(name: "Duplicate", token_digest: existing_token.token_digest)
    assert_not new_token.valid?
    assert_includes new_token.errors[:token_digest], "has already been taken"
  end

  test "name is required" do
    user = users(:one)
    api_token = user.api_tokens.new(name: nil)

    assert_not api_token.valid?
    assert_includes api_token.errors[:name], "can't be blank"
  end

  test "authenticate returns user for valid token" do
    raw = FIXTURE_RAW_TOKENS[:one]
    user = ApiToken.authenticate(raw)

    assert_equal api_tokens(:one).user, user
  end

  test "authenticate returns nil for invalid token" do
    user = ApiToken.authenticate("invalid_token")
    assert_nil user
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

  test "belongs to user" do
    api_token = api_tokens(:one)
    assert_equal users(:one), api_token.user
  end
end
