# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Ensure every existing user has a Primary agent + every board has its default
# columns. Useful after pulling a stale dev database forward to the new schema.
User.find_each do |user|
  user.agents.find_or_create_by!(name: "Primary") do |agent|
    agent.description = "Default agent"
  end

  user.boards.find_each(&:default_columns!)
end
