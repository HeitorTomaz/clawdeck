require "digest"

class ApiToken < ApplicationRecord
  belongs_to :agent

  # raw_token is set in-memory on creation so the plaintext token can be shown
  # to the user exactly once. It is never persisted.
  attr_accessor :raw_token

  validates :token_digest, presence: true, uniqueness: true
  validates :name, presence: true

  before_validation :generate_token, on: :create

  # Convenience accessor — most callers still want the user behind the token.
  delegate :user, to: :agent

  def self.authenticate(token)
    return nil if token.blank?

    digest = Digest::SHA256.hexdigest(token)
    api_token = find_by(token_digest: digest)
    return nil unless api_token

    api_token.touch(:last_used_at)
    api_token.agent
  end

  private

  def generate_token
    self.raw_token = SecureRandom.hex(32)
    self.token_digest = Digest::SHA256.hexdigest(raw_token)
  end
end
