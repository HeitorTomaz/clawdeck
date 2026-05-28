class BoardsController < ApplicationController
  before_action :set_board, only: [:show, :update, :destroy, :update_task_status]

  def index
    # Redirect to the first board
    @board = current_user.boards.first
    if @board
      redirect_to board_path(@board)
    else
      # Create a default board if none exists
      @board = current_user.boards.create!(name: "Personal", icon: "📋", color: "gray")
      redirect_to board_path(@board)
    end
  end

  def show
    @board_page = true
    session[:last_board_id] = @board.id
    @board_columns = @board.columns.includes(:assigned_agent)
    @tasks = @board.tasks.includes(:user, :assigned_agent)

    # Filter by tag if specified
    if params[:tag].present?
      @tasks = @tasks.where("? = ANY(tags)", params[:tag])
      @current_tag = params[:tag]
    end

    # Group tasks by their column (dynamic; was previously fixed status enum).
    tasks_by_column = @tasks.group_by(&:column_id)
    @tasks_by_column = @board_columns.each_with_object({}) do |column, hash|
      hash[column.id] = (tasks_by_column[column.id] || []).sort_by { |t| t.position || 0 }
    end

    # Get all unique tags for the sidebar filter
    @all_tags = @board.tasks.where.not(tags: []).pluck(:tags).flatten.uniq.sort

    # Get all boards for the sidebar
    @boards = current_user.boards

    # Agents and tokens for the sidebar / agent status display
    @agents = current_user.agents
  end

  def create
    @board = current_user.boards.new(board_params)

    if @board.save
      redirect_to board_path(@board), notice: "Board created."
    else
      redirect_to boards_path, alert: @board.errors.full_messages.join(", ")
    end
  end

  def update
    if @board.update(board_params)
      redirect_to board_path(@board), notice: "Board updated."
    else
      redirect_to board_path(@board), alert: @board.errors.full_messages.join(", ")
    end
  end

  def destroy
    # Don't allow deleting the last board
    if current_user.boards.count <= 1
      redirect_to board_path(@board), alert: "Cannot delete your only board."
      return
    end

    @board.destroy
    redirect_to boards_path, notice: "Board deleted."
  end

  # Drag-and-drop move endpoint. Kept the action name for backwards
  # compatibility with existing UI/JS hooks; it now moves tasks between
  # columns (column_id) rather than mutating a status enum.
  def update_task_status
    # Update positions for all tasks in a column (used after drag-reorder).
    if params[:task_ids].present?
      params[:task_ids].each_with_index do |task_id, index|
        task = @board.tasks.find(task_id)
        task.update_columns(position: index + 1)
      end
    end

    # If a specific task moved between columns.
    if params[:task_id].present? && params[:column_id].present?
      @task = @board.tasks.find(params[:task_id])
      column = @board.columns.find(params[:column_id])
      @task.activity_source = "web"
      @task.update!(column: column)
    end

    head :ok
  end

  private

  def set_board
    @board = current_user.boards.find(params[:id])
  end

  def board_params
    params.require(:board).permit(:name, :icon, :color)
  end
end
