class Task < ApplicationRecord
  belongs_to :user
  belongs_to :board
  belongs_to :column
  belongs_to :assigned_agent, class_name: "Agent", optional: true
  has_many :activities, class_name: "TaskActivity", dependent: :destroy
  has_many :subtasks, dependent: :destroy

  enum :priority, { none: 0, low: 1, medium: 2, high: 3 }, default: :none, prefix: true

  validates :name, presence: true
  validates :priority, inclusion: { in: priorities.keys }

  # Activity tracking - must be declared before callbacks that use it
  attr_accessor :activity_source, :actor_name, :actor_emoji, :activity_note

  # Store activity_source before commit so it survives the transaction
  before_save :store_activity_source_for_broadcast

  # Real-time broadcasts to user's board (only for API/background changes)
  # Skip broadcasts when activity_source is "web" since the UI already handles it
  after_create_commit :broadcast_create
  after_update_commit :broadcast_update
  after_destroy_commit :broadcast_destroy
  after_create :record_creation_activity
  after_update :record_update_activities

  # Webhook dispatch when a task enters an agent-assigned column flagged for
  # webhook -- both when created directly into such a column and when moved into one.
  after_create_commit :enqueue_agent_webhook, if: :should_fire_webhook_on_create?
  after_update_commit :enqueue_agent_webhook, if: :should_fire_webhook?

  # Position management - acts_as_list functionality without the gem
  before_create :set_position
  before_save :sync_completed_with_column
  before_update :track_completion_time, if: :will_save_change_to_column_id?

  # Order incomplete tasks by position, completed tasks by completion time (most recent first)
  scope :incomplete, -> { where(completed: false).reorder(position: :asc) }
  scope :completed, -> { where(completed: true).reorder(completed_at: :desc) }
  scope :assigned, -> { where.not(assigned_agent_id: nil) }
  scope :unassigned, -> { where(assigned_agent_id: nil) }
  default_scope { order(completed: :asc, position: :asc) }

  scope :filter_by, ->(params, board:) {
    rel = where(board: board)

    if params[:q].present?
      like = "%#{ActiveRecord::Base.sanitize_sql_like(params[:q])}%"
      rel = rel.where("name ILIKE :like OR description ILIKE :like", like: like)
    end

    tags = Array(params[:tag]).reject(&:blank?)
    tags.each do |tag|
      rel = rel.where("tags @> ARRAY[?]::varchar[]", tag)
    end

    cols = Array(params[:column]).reject(&:blank?)
    if cols.any?
      column_ids = board.columns.where(name: cols).pluck(:id)
      rel = rel.where(column_id: column_ids)
    end

    actors = Array(params[:touched_by]).reject(&:blank?)
    if actors.any?
      task_ids = TaskActivity.where(actor_type: actors).distinct.pluck(:task_id)
      rel = rel.where(id: task_ids)
    end

    rel
  }

  # Returns true if the task is sitting in the board's "Done" column.
  def done?
    column&.name == "Done"
  end

  # Convenience: assign this task to a given Agent (or nil to unassign).
  def assign_to_agent!(agent)
    update!(assigned_agent: agent)
  end

  def unassign_from_agent!
    update!(assigned_agent: nil)
  end

  private

  def set_position
    return if position.present?

    # Append: set position to end of list within the same column
    max_position = board.tasks.where(column_id: column_id).maximum(:position) || 0
    self.position = max_position + 1
  end

  def store_activity_source_for_broadcast
    @stored_activity_source = activity_source
  end

  def skip_broadcast?
    @stored_activity_source == "web" || activity_source == "web"
  end

  def sync_completed_with_column
    self.completed = (column&.name == "Done")
  end

  def track_completion_time
    if column&.name == "Done"
      self.completed_at = Time.current
    else
      self.completed_at = nil
    end
  end

  def record_creation_activity
    TaskActivity.record_creation(self, source: activity_source || "web", actor_name: actor_name, actor_emoji: actor_emoji, note: activity_note)
  end

  def record_update_activities
    source = activity_source || "web"

    # Track column changes (replaces legacy status change tracking)
    if saved_change_to_column_id?
      old_id, new_id = saved_change_to_column_id
      old_name = old_id && Column.unscoped.where(id: old_id).pick(:name)
      new_name = new_id && Column.unscoped.where(id: new_id).pick(:name)
      TaskActivity.record_status_change(self, old_status: old_name, new_status: new_name, source: source, actor_name: actor_name, actor_emoji: actor_emoji, note: activity_note)
    end

    # Track field changes
    tracked_changes = saved_changes.slice(*TaskActivity::TRACKED_FIELDS)
    TaskActivity.record_changes(self, tracked_changes, source: source, actor_name: actor_name, actor_emoji: actor_emoji, note: activity_note) if tracked_changes.any?
  end

  # Turbo Streams broadcasts for real-time updates
  def broadcast_create
    return if skip_broadcast?

    broadcast_to_board(
      action: :prepend,
      target: "column-#{column_id}",
      partial: "boards/task_card",
      locals: { task: self }
    )
    broadcast_column_count(column_id)
  end

  def broadcast_update
    return if skip_broadcast?

    # If column changed, handle move between columns
    if saved_change_to_column_id?
      old_column_id, new_column_id = saved_change_to_column_id
      # Remove from old column
      broadcast_to_board(action: :remove, target: "task_#{id}")
      # Add to new column
      broadcast_to_board(
        action: :prepend,
        target: "column-#{new_column_id}",
        partial: "boards/task_card",
        locals: { task: self }
      )
      broadcast_column_count(old_column_id)
      broadcast_column_count(new_column_id)
    else
      # Just update the card in place
      broadcast_to_board(
        action: :replace,
        target: "task_#{id}",
        partial: "boards/task_card",
        locals: { task: self }
      )
    end
  end

  def broadcast_destroy
    return if skip_broadcast?

    # Cache values before they become inaccessible
    cached_board_id = board_id
    cached_column_id = column_id
    cached_id = id
    stream = "board_#{cached_board_id}"

    Turbo::StreamsChannel.broadcast_action_to(stream, action: :remove, target: "task_#{cached_id}")

    # Update column count
    count = Board.find(cached_board_id).tasks.where(column_id: cached_column_id).count
    Turbo::StreamsChannel.broadcast_action_to(
      stream,
      action: :replace,
      target: "column-#{cached_column_id}-count",
      html: %(<span id="column-#{cached_column_id}-count" style="font-size:11px;font-weight:600;color:#444;background:rgba(255,255,255,0.04);padding:0 7px;border-radius:5px;line-height:20px">#{count}</span>)
    )
  end

  def broadcast_column_count(column_id)
    count = board.tasks.where(column_id: column_id).count
    broadcast_to_board(
      action: :replace,
      target: "column-#{column_id}-count",
      html: %(<span id="column-#{column_id}-count" style="font-size:11px;font-weight:600;color:#444;background:rgba(255,255,255,0.04);padding:0 7px;border-radius:5px;line-height:20px">#{count}</span>)
    )
  end

  def board_stream_name
    "board_#{board_id}"
  end

  def broadcast_to_board(action:, target:, **options)
    Turbo::StreamsChannel.broadcast_action_to(board_stream_name, action: action, target: target, **options)
  end

  def should_fire_webhook?
    saved_change_to_column_id? &&
      column&.webhook_enabled? &&
      column.assigned_agent&.webhook_agent_id.present?
  end

  # On create the task is dropped straight into a column, so mirror
  # should_fire_webhook? without the column-change check.
  def should_fire_webhook_on_create?
    column&.webhook_enabled? &&
      column.assigned_agent&.webhook_agent_id.present?
  end

  def enqueue_agent_webhook
    AgentWebhookJob.perform_later(id, column_id)
  end
end
