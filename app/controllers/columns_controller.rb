# Web (HTML/Turbo) CRUD for columns on a board. Scoped through the current
# user's boards — fetching by board_id ensures users can't touch columns on
# boards they don't own.
class ColumnsController < ApplicationController
  before_action :set_board
  before_action :set_column, only: [ :show, :edit, :update, :destroy ]

  def index
    @columns = @board.columns
    respond_to do |format|
      format.html
      format.json { render json: @columns }
    end
  end

  def show
    render layout: false
  end

  def new
    @column = @board.columns.new
    render layout: false
  end

  def create
    attrs = column_params
    attrs[:position] ||= (@board.columns.maximum(:position) || -1) + 1
    @column = @board.columns.new(attrs)

    if @column.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to board_path(@board), notice: "Column added." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :new, status: :unprocessable_entity, layout: false }
        format.html { render :new, status: :unprocessable_entity, layout: false }
      end
    end
  end

  def edit
    render layout: false
  end

  def update
    if @column.update(column_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to board_path(@board), notice: "Column updated." }
      end
    else
      render :edit, status: :unprocessable_entity, layout: false
    end
  end

  def destroy
    task_count = @column.tasks.count
    if task_count.positive?
      respond_to do |format|
        format.html do
          redirect_to board_path(@board),
            alert: "Cannot delete '#{@column.name}': it still has #{task_count} #{'task'.pluralize(task_count)}. Move or delete them first."
        end
        format.json do
          render json: {
            detail: "Column has #{task_count} #{'task'.pluralize(task_count)}",
            column_id: @column.id,
            task_count: task_count
          }, status: :unprocessable_entity
        end
      end
      return
    end

    @column.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to board_path(@board), notice: "Column deleted." }
      format.json { head :no_content }
    end
  end

  # POST /boards/:board_id/columns/reorder
  # Body: order=[1,3,2] (or JSON {order:[...]})
  def reorder
    ids = Array(params[:order]).map(&:to_i)
    if ids.empty?
      head :unprocessable_entity
      return
    end

    columns = @board.columns.where(id: ids).index_by(&:id)
    if (ids - columns.keys).any? || (columns.keys - ids).any?
      head :unprocessable_entity
      return
    end

    Column.transaction do
      columns.each_value.with_index do |col, idx|
        col.update_columns(position: -(idx + 1) - 1000)
      end
      ids.each_with_index do |col_id, idx|
        columns[col_id].update_columns(position: idx)
      end
    end

    head :ok
  end

  private

  def set_board
    @board = current_user.boards.find(params[:board_id])
  end

  def set_column
    @column = @board.columns.find(params[:id])
  end

  def column_params
    permitted = params.require(:column).permit(:name, :position, :assigned_agent_id)
    # Restrict assigned_agent_id to agents the current user owns.
    if permitted[:assigned_agent_id].present?
      unless current_user.agents.exists?(id: permitted[:assigned_agent_id])
        permitted.delete(:assigned_agent_id)
      end
    end
    permitted
  end
end
