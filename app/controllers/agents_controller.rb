# Web CRUD for the current user's Agents. An Agent represents an LLM/agent
# identity that owns ApiTokens and can be assigned to tasks/columns.
class AgentsController < ApplicationController
  before_action :set_agent, only: [ :show, :edit, :update, :destroy, :regenerate_token ]

  def index
    @agents = current_user.agents.includes(:api_tokens).order(:name)
  end

  # POST /agents/:id/regenerate_token
  # Wipes existing tokens for this agent, creates a fresh one, and renders
  # the index with @new_raw_token / @new_raw_token_agent_id set (one-time view).
  def regenerate_token
    @agent.api_tokens.destroy_all
    token_record = @agent.api_tokens.create!(name: params[:token_name].presence || "Default")
    @agents = current_user.agents.includes(:api_tokens).order(:name)
    @new_raw_token = token_record.respond_to?(:raw_token) ? token_record.raw_token : nil
    @new_raw_token_agent_id = @agent.id
    flash.now[:notice] = "API token regenerated for #{@agent.name}. Copy it now — it won't be shown again."
    render :index
  end

  def show
    @api_tokens = @agent.api_tokens.order(created_at: :desc)
  end

  def new
    @agent = current_user.agents.new
  end

  def create
    @agent = current_user.agents.new(agent_params)
    if @agent.save
      redirect_to agent_path(@agent), notice: "Agent created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @agent.update(agent_params)
      redirect_to agent_path(@agent), notice: "Agent updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Deleting an agent is allowed even if it owns tasks/columns — the model
  # declares `dependent: :nullify` so those records simply lose their agent.
  def destroy
    @agent.destroy
    redirect_to agents_path, notice: "Agent deleted."
  end

  private

  def set_agent
    @agent = current_user.agents.find(params[:id])
  end

  def agent_params
    params.require(:agent).permit(:name, :description, :webhook_agent_id)
  end
end
