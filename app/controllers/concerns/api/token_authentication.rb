module Api
  module TokenAuthentication
    extend ActiveSupport::Concern

    included do
      before_action :authenticate_api_token
      after_action :track_api_usage
      attr_reader :current_agent
    end

    private

    def authenticate_api_token
      token = extract_token_from_header
      @current_agent = ApiToken.authenticate(token)

      unless @current_agent
        render json: { error: "Unauthorized" }, status: :unauthorized
        return
      end

      update_agent_info_from_headers
    end

    # The user that owns the currently authenticated agent. Many controllers
    # still scope queries by user (boards, tasks belong to user) so we expose
    # this as a convenience.
    def current_user
      @current_agent&.user
    end

    # Pull token out of either the dedicated X-Agent-Token header or the
    # legacy Authorization: Bearer <token> header. X-Agent-Token wins.
    def extract_token_from_header
      header_token = request.headers["X-Agent-Token"]
      return header_token if header_token.present?

      auth_header = request.headers["Authorization"]
      return nil unless auth_header

      match = auth_header.match(/\ABearer\s+(.+)\z/i)
      match&.[](1)
    end

    def track_api_usage
      ApiUsageRecord.track!(current_user) if current_user
    end

    def update_agent_info_from_headers
      agent_name = request.headers["X-Agent-Name"]
      agent_emoji = request.headers["X-Agent-Emoji"]

      updates = { agent_last_active_at: Time.current }
      updates[:agent_name] = agent_name if agent_name.present?
      updates[:agent_emoji] = agent_emoji if agent_emoji.present?

      # Best-effort metadata refresh on the Agent record. If the columns
      # don't exist (legacy schema), skip silently.
      return unless current_agent

      writable = updates.select { |attr, _| current_agent.class.column_names.include?(attr.to_s) }
      current_agent.update_columns(writable) if writable.any?
    end
  end
end
