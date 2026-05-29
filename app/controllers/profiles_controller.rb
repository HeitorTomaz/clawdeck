class ProfilesController < ApplicationController
  def show
    @user = current_user
    @agents = current_user.agents.includes(:api_tokens).order(:name)
    # @raw_token gets set by regenerate_api_token so the view can show it
    # exactly once.
    @raw_token ||= nil
  end

  def update
    @user = current_user

    if params[:user][:remove_avatar] == "1"
      @user.avatar.purge if @user.avatar.attached?
      @user.avatar_url = nil
    end

    if @user.update(profile_params)
      redirect_to settings_path, notice: "Profile updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  # Generates a fresh ApiToken under a specific Agent. If agent_id is omitted,
  # defaults to the user's first agent (creating a Primary agent on the fly so
  # legacy flows keep working).
  def regenerate_api_token
    agent = resolve_agent_for_token

    # Wipe existing tokens for this agent so only the freshest one is active.
    agent.api_tokens.destroy_all

    token_record = agent.api_tokens.create!(name: params[:token_name].presence || "Default")

    @user = current_user
    @agents = current_user.agents.includes(:api_tokens).order(:name)
    @raw_token = token_record.respond_to?(:raw_token) ? token_record.raw_token : nil
    @new_raw_token = @raw_token
    @new_token_agent_id = agent.id
    @new_raw_token_agent_id = agent.id
    flash.now[:notice] = "API token regenerated for #{agent.name}. Copy it now — it won't be shown again."
    render :show
  end

  private

  def resolve_agent_for_token
    if params[:agent_id].present?
      current_user.agents.find(params[:agent_id])
    else
      current_user.agents.first || current_user.agents.create!(name: "Primary")
    end
  end

  def profile_params
    params.expect(user: [ :email_address, :avatar ])
  end
end
