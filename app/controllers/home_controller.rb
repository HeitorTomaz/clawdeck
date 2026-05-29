class HomeController < ApplicationController
  def show
    @user = current_user
    @boards = current_user.boards

    # Active columns = anything that's NOT "Done". Names match the default 5-column set.
    active_column_names = [ "Inbox", "Up Next", "In Progress", "In Review" ]

    # Today's tasks: due today OR sitting in an "active work" column
    @today_tasks = current_user.tasks
      .joins(:column)
      .where("tasks.due_date = ? OR columns.name IN (?)", Date.today, [ "Up Next", "In Progress" ])
      .where(completed: false)
      .includes(:board, :column)
      .reorder(position: :asc)
      .limit(10)

    # Also include recently completed today
    @completed_today = current_user.tasks
      .where(completed: true)
      .where("completed_at >= ?", Date.today.beginning_of_day)
      .includes(:board)
      .reorder(completed_at: :desc)
      .limit(5)

    @all_today_tasks = @today_tasks + @completed_today

    # Agent tasks currently being worked on (assigned to any Agent + not yet completed)
    @agent_tasks_count = current_user.tasks.where.not(assigned_agent_id: nil).where(completed: false).count

    # Agent updates (last 24h)
    @agent_updates = TaskActivity
      .joins(:task)
      .where(tasks: { user_id: current_user.id })
      .where(actor_type: "agent")
      .where("task_activities.created_at > ?", 24.hours.ago)
      .includes(:task)
      .order(created_at: :desc)
      .limit(5)

    # Weekly stats — count tasks completed each day
    week_start = Date.today.beginning_of_week(:monday)
    @week_stats = (0..6).map do |i|
      date = week_start + i.days
      base = TaskActivity
        .joins(:task)
        .where(tasks: { user_id: current_user.id })
        .where(task_activities: { created_at: date.all_day })
        .where("(task_activities.action = 'moved' AND task_activities.new_value = 'Done') OR task_activities.action = 'completed'")

      {
        day: date.strftime("%a"),
        date: date,
        you: base.where.not(actor_type: "agent").count,
        agent: base.where(actor_type: "agent").count
      }
    end

    # Summary counts (column-based)
    @completed_count = @week_stats.sum { |d| d[:you] + d[:agent] }
    @in_progress_count = current_user.tasks.joins(:column).where(columns: { name: "In Progress" }, completed: false).count
    @upcoming_count = current_user.tasks.joins(:column).where(columns: { name: [ "Inbox", "Up Next" ] }, completed: false).count
    @completed_today_count = @completed_today.count
  end
end
