require "net/http"
require "uri"
require "json"

# Dispatches an OpenClaw "agent" webhook (POST /hooks/agent) when a task lands
# on a column whose assigned agent has a webhook_agent_id.
#
# Reads ENV['OPENCLAW_HOOKS_URL'] (e.g. https://gw.example/hooks/agent) and
# ENV['OPENCLAW_HOOKS_TOKEN'] (the dedicated hooks shared secret). If either is
# blank, the dispatcher logs a warning and no-ops (so tests + envs without the
# gateway don't error). Non-2xx responses raise:
#   * TransientError for 5xx (caller retries)
#   * PermanentError for 4xx (caller logs and gives up)
class AgentWebhookDispatcher
  class TransientError < StandardError; end
  class PermanentError < StandardError; end

  OPEN_TIMEOUT = 3
  READ_TIMEOUT = 10

  def initialize(task, agent, http_client: nil)
    @task = task
    @agent = agent
    @http_client = http_client
  end

  def call
    url = ENV["OPENCLAW_HOOKS_URL"]
    token = ENV["OPENCLAW_HOOKS_TOKEN"]
    if url.blank? || token.blank?
      Rails.logger.warn("[AgentWebhookDispatcher] missing OPENCLAW_HOOKS_URL or OPENCLAW_HOOKS_TOKEN; skipping (task_id=#{@task.id})")
      return :skipped
    end

    body = {
      name: "clawdeck-task-#{@task.id}",
      agentId: @agent.webhook_agent_id,
      message: hook_message
    }.to_json

    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    response = post_json(url, body, token)
    duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round

    code = response.code.to_i
    case code
    when 200..299
      Rails.logger.info(
        "[AgentWebhookDispatcher] ok task_id=#{@task.id} agent=#{@agent.name} " \
        "openclaw_agent=#{@agent.webhook_agent_id} column=#{@task.column&.name} http=#{code} duration_ms=#{duration_ms}"
      )
      response
    when 400..499
      Rails.logger.warn(
        "[AgentWebhookDispatcher] 4xx task_id=#{@task.id} agent=#{@agent.name} " \
        "http=#{code} duration_ms=#{duration_ms} body=#{response.body.to_s.byteslice(0, 200)}"
      )
      raise PermanentError, "OpenClaw hook returned #{code}"
    else
      Rails.logger.warn(
        "[AgentWebhookDispatcher] 5xx task_id=#{@task.id} agent=#{@agent.name} " \
        "http=#{code} duration_ms=#{duration_ms}"
      )
      raise TransientError, "OpenClaw hook returned #{code}"
    end
  end

  private

  # Message sent to the OpenClaw agent turn. If the task's column defines a
  # custom webhook_message, it is sent verbatim (the column owner controls the
  # exact prompt). Otherwise a human-readable briefing is built from the task.
  def hook_message
    custom = @task.column&.webhook_message
    return render_template(custom) if custom.present?

    lines = []
    lines << "Nova task atribuida no ClawDeck."
    lines << "Board: #{@task.column&.board&.name}" if @task.column&.board
    lines << "Coluna: #{@task.column&.name}" if @task.column
    lines << "Task: #{@task.name}" if @task.name.present?
    lines << "Descricao: #{@task.description}" if @task.description.present?
    lines << "Dica: #{@task.agent_hint}" if @task.respond_to?(:agent_hint) && @task.agent_hint.present?
    lines.join("\n")
  end

  # Interpolates {{placeholder}} tokens (see Column::WEBHOOK_PLACEHOLDERS) with
  # the card's fields. Unknown tokens are left untouched so typos stay visible.
  def render_template(template)
    values = {
      "task.name"        => @task.name.to_s,
      "task.description" => @task.description.to_s,
      "task.agent_hint"  => (@task.respond_to?(:agent_hint) ? @task.agent_hint.to_s : ""),
      "task.id"          => @task.id.to_s,
      "board"            => @task.column&.board&.name.to_s,
      "column"           => @task.column&.name.to_s
    }
    template.gsub(/\{\{\s*([\w.]+)\s*\}\}/) { |m| values.key?(Regexp.last_match(1)) ? values[Regexp.last_match(1)] : m }
  end

  def post_json(url, body, token)
    return @http_client.call(url, body, token) if @http_client

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = OPEN_TIMEOUT
    http.read_timeout = READ_TIMEOUT

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Authorization"] = "Bearer #{token}"
    request["Content-Type"] = "application/json"
    request.body = body

    http.request(request)
  end
end
