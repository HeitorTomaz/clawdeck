class Agent < ApplicationRecord
  belongs_to :user
  has_many :api_tokens, dependent: :destroy
  has_many :tasks_assigned, class_name: "Task", foreign_key: :assigned_agent_id, dependent: :nullify
  has_many :columns_assigned, class_name: "Column", foreign_key: :assigned_agent_id, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
