class Board < ApplicationRecord
  belongs_to :user
  has_many :columns, -> { order(position: :asc) }, dependent: :destroy
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
  validates :position, presence: true

  before_create :set_position

  # Default scope orders by position
  default_scope { order(position: :asc) }

  # Available board colors (Tailwind-compatible)
  COLORS = %w[gray red orange amber yellow lime green emerald teal cyan sky blue indigo violet purple fuchsia pink rose].freeze

  # Available board icons (emojis)
  DEFAULT_ICONS = %w[📋 📝 🎯 🚀 💡 🔧 📊 🎨 📚 🏠 💼 🎮 🎵 📸 ✨ 🦞].freeze

  # Names + positions for the default columns created on every new board.
  # Order matters: position is the array index.
  DEFAULT_COLUMN_NAMES = %w[Inbox Up\ Next In\ Progress In\ Review Done].freeze

  # Idempotently creates the 5 default columns on this board.
  # Safe to call multiple times (used in onboarding + migration backfill).
  def default_columns!
    DEFAULT_COLUMN_NAMES.each_with_index do |name, idx|
      columns.find_or_create_by!(name: name) do |col|
        col.position = idx
      end
    end
    columns.reload
  end

  def self.create_onboarding_for(user)
    board = user.boards.create!(
      name: "Getting Started",
      icon: "🚀",
      color: "blue"
    )
    board.default_columns!

    inbox = board.columns.find_by!(name: "Inbox")
    up_next = board.columns.find_by!(name: "Up Next")

    tasks = [
      {
        name: "👋 Welcome to ClawDeck!",
        description: "Your mission control for AI agents. Drag tasks between columns, and your agent picks up what you assign. Think of it as a shared kanban with your AI coworker.",
        column: up_next,
        position: 0
      },
      {
        name: "🔗 Connect your agent",
        description: "Go to Settings → copy the integration prompt → paste it into your agent's config. Once connected, you'll see your agent appear in the header.",
        column: inbox,
        position: 0
      },
      {
        name: "✅ Assign your first task",
        description: "Create a task, then right-click → \"Assign to Agent\". Your agent will pick it up and start working. Watch the activity feed for updates!",
        column: inbox,
        position: 1
      },
      {
        name: "💡 Example: Research task",
        description: "\"Research the top 5 competitors to [product] and summarize their pricing models.\" — Great for agents with web access.",
        column: inbox,
        position: 2
      },
      {
        name: "💡 Example: Code task",
        description: "\"Add a dark mode toggle to the settings page. Use Tailwind classes.\" — Perfect for coding agents.",
        column: inbox,
        position: 3
      },
      {
        name: "💡 Example: Writing task",
        description: "\"Draft a welcome email for new users. Keep it short, friendly, 3 paragraphs max.\" — Works with any agent.",
        column: inbox,
        position: 4
      },
      {
        name: "🎯 Try it yourself!",
        description: "Delete these cards and create your first real task. Be specific — your agent works best with clear instructions.",
        column: up_next,
        position: 1
      }
    ]

    tasks.each do |task_attrs|
      board.tasks.create!(task_attrs.merge(user: user))
    end

    board
  end

  private

  def set_position
    return if position.present? && position > 0

    max_position = user.boards.unscoped.where(user_id: user_id).maximum(:position) || 0
    self.position = max_position + 1
  end
end
