module Api
  module V1
    module Agent
      class ColumnsController < BaseController
        before_action :set_board
        before_action :set_column, only: [ :show, :update, :destroy ]

        # GET /api/v1/agent/boards/:board_id/columns
        def index
          render json: @board.columns.map { |c| column_json(c) }
        end

        # GET /api/v1/agent/boards/:board_id/columns/:id
        def show
          render json: column_json(@column)
        end

        # POST /api/v1/agent/boards/:board_id/columns
        def create
          attrs = column_params
          attrs[:position] ||= (@board.columns.maximum(:position) || -1) + 1

          @column = @board.columns.new(attrs)

          if @column.save
            render json: column_json(@column), status: :created
          else
            render json: { error: @column.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        end

        # PATCH /api/v1/agent/boards/:board_id/columns/:id
        def update
          if @column.update(column_params)
            render json: column_json(@column)
          else
            render json: { error: @column.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        end

        # DELETE /api/v1/agent/boards/:board_id/columns/:id
        # Refuses (422) if the column still has tasks.
        def destroy
          task_count = @column.tasks.count
          if task_count.positive?
            render json: {
              detail: "Column has #{task_count} #{'task'.pluralize(task_count)}",
              column_id: @column.id,
              task_count: task_count
            }, status: :unprocessable_entity
            return
          end

          @column.destroy
          head :no_content
        end

        # POST /api/v1/agent/boards/:board_id/columns/reorder
        # Body: { order: [col_id_1, col_id_2, ...] }
        # Applies positions atomically. Uses a two-phase update to avoid
        # unique-index collisions on (board_id, position).
        def reorder
          ids = Array(params[:order]).map(&:to_i)
          if ids.empty?
            render json: { error: "order must be a non-empty array of column ids" }, status: :unprocessable_entity
            return
          end

          columns = @board.columns.where(id: ids).index_by(&:id)
          unknown = ids - columns.keys
          if unknown.any?
            render json: { error: "Unknown column ids: #{unknown.join(', ')}" }, status: :unprocessable_entity
            return
          end

          missing = columns.keys - ids
          if missing.any?
            render json: { error: "order must include every column in the board" }, status: :unprocessable_entity
            return
          end

          Column.transaction do
            # Phase 1: park positions at negative offsets to dodge the unique
            # index on (board_id, position) during the swap.
            columns.each_value.with_index do |col, idx|
              col.update_columns(position: -(idx + 1) - 1000)
            end

            # Phase 2: apply the requested order.
            ids.each_with_index do |col_id, idx|
              columns[col_id].update_columns(position: idx)
            end
          end

          render json: @board.columns.reload.map { |c| column_json(c) }
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
          # Scope assigned_agent_id to the current user's agents.
          if permitted[:assigned_agent_id].present?
            unless current_user.agents.exists?(id: permitted[:assigned_agent_id])
              permitted.delete(:assigned_agent_id)
            end
          end
          permitted
        end

        def column_json(column)
          agent = column.assigned_agent
          {
            id: column.id,
            board_id: column.board_id,
            name: column.name,
            position: column.position,
            assigned_agent: agent ? { id: agent.id, name: agent.name } : nil,
            task_count: column.tasks.size,
            created_at: column.created_at.iso8601,
            updated_at: column.updated_at.iso8601
          }
        end
      end
    end
  end
end
