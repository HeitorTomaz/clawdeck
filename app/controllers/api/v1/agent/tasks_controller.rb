module Api
  module V1
    module Agent
      class TasksController < BaseController
        before_action :set_task, only: [ :show, :update, :destroy, :complete, :claim, :unclaim, :assign, :unassign ]

        # GET /api/v1/agent/tasks
        # Filters: ?board_id, ?column_id OR ?column_name, ?blocked, ?tag,
        #          ?completed, ?priority, ?assigned (true/false).
        # NOTE: ?status is intentionally NOT supported (breaking change in v1).
        def index
          @tasks = current_user.tasks

          if params[:board_id].present?
            @tasks = @tasks.where(board_id: params[:board_id])
          end

          if params[:column_id].present?
            @tasks = @tasks.where(column_id: params[:column_id])
          elsif params[:column_name].present?
            column_ids = Column.joins(:board)
              .where(boards: { user_id: current_user.id }, name: params[:column_name])
              .pluck(:id)
            @tasks = @tasks.where(column_id: column_ids)
          end

          if params[:blocked].present?
            blocked = ActiveModel::Type::Boolean.new.cast(params[:blocked])
            @tasks = @tasks.where(blocked: blocked)
          end

          if params[:tag].present?
            @tasks = @tasks.where("? = ANY(tags)", params[:tag])
          end

          if params[:completed].present?
            completed = ActiveModel::Type::Boolean.new.cast(params[:completed])
            @tasks = @tasks.where(completed: completed)
          end

          if params[:priority].present? && Task.priorities.key?(params[:priority])
            @tasks = @tasks.where(priority: params[:priority])
          end

          if params[:assigned].present?
            assigned = ActiveModel::Type::Boolean.new.cast(params[:assigned])
            @tasks = if assigned
              @tasks.where.not(assigned_agent_id: nil)
            else
              @tasks.where(assigned_agent_id: nil)
            end
          end

          @tasks = @tasks.includes(:column, :assigned_agent).reorder(:column_id, :position)
          render json: @tasks.map { |task| task_json(task) }
        end

        # GET /api/v1/agent/tasks/next
        def next
          unless current_user.agent_auto_mode?
            head :no_content
            return
          end

          up_next_column = current_user.boards
            .joins(:columns)
            .where(columns: { name: "Up Next" })
            .pluck("columns.id")

          @task = current_user.tasks
            .where(column_id: up_next_column, blocked: false, agent_claimed_at: nil)
            .reorder(priority: :desc, position: :asc)
            .first

          if @task
            render json: task_json(@task)
          else
            head :no_content
          end
        end

        # GET /api/v1/agent/tasks/pending_attention
        def pending_attention
          unless current_user.agent_auto_mode?
            render json: []
            return
          end

          in_progress_column_ids = Column.joins(:board)
            .where(boards: { user_id: current_user.id }, name: "In Progress")
            .pluck(:id)

          @tasks = current_user.tasks
            .where(column_id: in_progress_column_ids)
            .where.not(agent_claimed_at: nil)

          render json: @tasks.map { |task| task_json(task) }
        end

        # GET /api/v1/agent/tasks/:id
        def show
          render json: task_json(@task)
        end

        # POST /api/v1/agent/tasks
        # Requires column_id OR column_name (resolved against caller's boards).
        def create
          board_id = params.dig(:task, :board_id) || params[:board_id]
          board = if board_id.present?
            current_user.boards.find(board_id)
          else
            current_user.boards.first || current_user.boards.create!(name: "Personal", icon: "📋", color: "gray")
          end

          column = resolve_column_for_board(board)
          unless column
            render json: { error: "column_id or column_name required" }, status: :unprocessable_entity
            return
          end

          @task = board.tasks.new(task_create_params)
          @task.user = current_user
          @task.column = column
          set_task_activity_info(@task)

          if @task.save
            render json: task_json(@task), status: :created
          else
            render json: { error: @task.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        end

        # PATCH /api/v1/agent/tasks/:id
        # Accepts {column_id: X} or {column_name: "Y"} to move tasks across
        # columns. Other task attributes via task_params.
        def update
          set_task_activity_info(@task)

          attrs = task_update_params

          # Allow column_id / column_name at top level OR nested under :task.
          requested_column_id   = params[:column_id]   || params.dig(:task, :column_id)
          requested_column_name = params[:column_name] || params.dig(:task, :column_name)

          if requested_column_id.present?
            column = @task.board.columns.find_by(id: requested_column_id)
            return render(json: { error: "Column not found in this board" }, status: :unprocessable_entity) unless column
            attrs[:column_id] = column.id
          elsif requested_column_name.present?
            column = @task.board.columns.find_by(name: requested_column_name)
            return render(json: { error: "Column '#{requested_column_name}' not found in this board" }, status: :unprocessable_entity) unless column
            attrs[:column_id] = column.id
          end

          if @task.update(attrs)
            render json: task_json(@task)
          else
            render json: { error: @task.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        end

        # DELETE /api/v1/agent/tasks/:id
        def destroy
          @task.destroy!
          head :no_content
        end

        # PATCH /api/v1/agent/tasks/:id/complete
        # Toggles task between its board's Done column and Inbox column.
        def complete
          set_task_activity_info(@task)
          board = @task.board
          target_name = @task.column&.name == "Done" ? "Inbox" : "Done"
          target_column = board.columns.find_by(name: target_name) || board.columns.first
          @task.update!(column: target_column, completed: target_name == "Done", completed_at: target_name == "Done" ? Time.current : nil)
          render json: task_json(@task)
        end

        # PATCH /api/v1/agent/tasks/:id/claim
        def claim
          set_task_activity_info(@task)
          board = @task.board
          in_progress = board.columns.find_by(name: "In Progress")
          attrs = { agent_claimed_at: Time.current, assigned_agent_id: current_agent.id }
          attrs[:column_id] = in_progress.id if in_progress
          @task.update!(attrs)
          render json: task_json(@task)
        end

        # PATCH /api/v1/agent/tasks/:id/unclaim
        def unclaim
          set_task_activity_info(@task)
          @task.update!(agent_claimed_at: nil)
          render json: task_json(@task)
        end

        # PATCH /api/v1/agent/tasks/:id/assign
        # Body: { agent_id: <id> }, defaults to current_agent.
        def assign
          set_task_activity_info(@task)
          agent_id = params[:agent_id] || params.dig(:task, :agent_id) || current_agent.id
          agent = current_user.agents.find_by(id: agent_id)
          return render(json: { error: "Agent not found" }, status: :unprocessable_entity) unless agent
          @task.update!(assigned_agent_id: agent.id, assigned_at: Time.current)
          render json: task_json(@task)
        end

        # PATCH /api/v1/agent/tasks/:id/unassign
        def unassign
          set_task_activity_info(@task)
          @task.update!(assigned_agent_id: nil, assigned_at: nil)
          render json: task_json(@task)
        end

        private

        def set_task
          @task = current_user.tasks.find(params[:id])
        end

        def set_task_activity_info(task)
          task.activity_source = "api"
          task.actor_name = request.headers["X-Agent-Name"] || current_agent&.name
          task.actor_emoji = request.headers["X-Agent-Emoji"]
          task.activity_note = params[:activity_note] || params.dig(:task, :activity_note)
        end

        # Resolve a column for create. Accepts (in priority order):
        # 1) params[:column_id] / task[:column_id]
        # 2) params[:column_name] / task[:column_name]
        # 3) board's first column
        def resolve_column_for_board(board)
          col_id   = params[:column_id]   || params.dig(:task, :column_id)
          col_name = params[:column_name] || params.dig(:task, :column_name)

          if col_id.present?
            board.columns.find_by(id: col_id)
          elsif col_name.present?
            board.columns.find_by(name: col_name)
          else
            board.columns.first
          end
        end

        def task_create_params
          params.require(:task).permit(:name, :description, :priority, :due_date, :blocked, :board_id, tags: [])
        end

        def task_update_params
          params.require(:task).permit(:name, :description, :priority, :due_date, :blocked, :board_id, tags: [])
        rescue ActionController::ParameterMissing
          {}
        end

        def task_json(task)
          assigned_agent = task.assigned_agent
          {
            id: task.id,
            name: task.name,
            description: task.description,
            priority: task.priority,
            blocked: task.blocked,
            tags: task.tags || [],
            completed: task.completed,
            completed_at: task.completed_at&.iso8601,
            due_date: task.due_date&.iso8601,
            position: task.position,
            column_id: task.column_id,
            column_name: task.column&.name,
            assigned_agent: assigned_agent ? { id: assigned_agent.id, name: assigned_agent.name } : nil,
            assigned_at: task.assigned_at&.iso8601,
            agent_claimed_at: task.agent_claimed_at&.iso8601,
            board_id: task.board_id,
            url: "https://clawdeck.io/boards/#{task.board_id}/tasks/#{task.id}",
            created_at: task.created_at.iso8601,
            updated_at: task.updated_at.iso8601
          }
        end
      end
    end
  end
end
