class Column < ApplicationRecord
  belongs_to :board
  belongs_to :assigned_agent, class_name: "Agent", optional: true
  has_many :tasks, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :board_id }
  validates :position, presence: true, uniqueness: { scope: :board_id }

  default_scope { order(position: :asc) }
  scope :ordered, -> { order(position: :asc) }
end
