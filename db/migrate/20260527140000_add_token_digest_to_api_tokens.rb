require "digest"

class AddTokenDigestToApiTokens < ActiveRecord::Migration[8.0]
  def up
    add_column :api_tokens, :token_digest, :string
    add_index :api_tokens, :token_digest, unique: true

    # Allow legacy plaintext token column to be null for new records
    change_column_null :api_tokens, :token, true

    # Backfill digests for any existing tokens
    ApiToken.reset_column_information
    ApiToken.find_each do |api_token|
      next if api_token.token.blank?
      api_token.update_columns(token_digest: Digest::SHA256.hexdigest(api_token.token))
    end
  end

  def down
    remove_index :api_tokens, :token_digest
    remove_column :api_tokens, :token_digest
    change_column_null :api_tokens, :token, false
  end
end
