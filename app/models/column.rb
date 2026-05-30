class Column < ApplicationRecord
  # Placeholders usable in webhook_message (token => human description).
  # Single source of truth for both the dispatcher (interpolation) and the
  # column form UI (the list shown next to the message box).
  WEBHOOK_PLACEHOLDERS = {
    "task.name"        => "Titulo do card",
    "task.description" => "Descricao do card",
    "task.agent_hint"  => "Dica para o agente",
    "task.id"          => "ID do card",
    "board"            => "Nome do board",
    "column"           => "Nome da coluna"
  }.freeze

  belongs_to :board
  belongs_to :assigned_agent, class_name: "Agent", optional: true
  has_many :tasks, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :board_id }
  validates :position, presence: true, uniqueness: { scope: :board_id }

  default_scope { order(position: :asc) }
  scope :ordered, -> { order(position: :asc) }
end
