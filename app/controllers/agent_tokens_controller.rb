class AgentTokensController < ApplicationController
  before_action :set_agent

  def destroy
    token = @agent.api_tokens.find(params[:id])
    token.destroy
    redirect_to agents_path, notice: "Token revoked."
  end

  private

  def set_agent
    @agent = current_user.agents.find(params[:agent_id])
  end
end
