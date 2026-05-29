require "net/http"
require "uri"
require "json"
require "securerandom"

# Dispatches a "cron.run" admin RPC call to the configured OpenClaw gateway
# when a task lands on a column whose assigned agent has a webhook_cron_id.
#
# Reads ENV['OPENCLAW_RPC_URL'] and ENV['OPENCLAW_GATEWAY_TOKEN']. If either is
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
    url = ENV["OPENCLAW_RPC_URL"]
    token = ENV["OPENCLAW_GATEWAY_TOKEN"]
    if url.blank? || token.blank?
      Rails.logger.warn("[AgentWebhookDispatcher] missing OPENCLAW_RPC_URL or OPENCLAW_GATEWAY_TOKEN; skipping (task_id=#{@task.id})")
      return :skipped
    end

    body = {
      id: "clawdeck-#{@task.id}-#{SecureRandom.hex(4)}",
      method: "cron.run",
      params: { id: @agent.webhook_cron_id }
    }.to_json

    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    response = post_json(url, body, token)
    duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round

    code = response.code.to_i
    case code
    when 200..299
      Rails.logger.info(
        "[AgentWebhookDispatcher] ok task_id=#{@task.id} agent=#{@agent.name} " \
        "column=#{@task.column&.name} http=#{code} duration_ms=#{duration_ms}"
      )
      response
    when 400..499
      Rails.logger.warn(
        "[AgentWebhookDispatcher] 4xx task_id=#{@task.id} agent=#{@agent.name} " \
        "http=#{code} duration_ms=#{duration_ms} body=#{response.body.to_s.byteslice(0, 200)}"
      )
      raise PermanentError, "OpenClaw RPC returned #{code}"
    else
      Rails.logger.warn(
        "[AgentWebhookDispatcher] 5xx task_id=#{@task.id} agent=#{@agent.name} " \
        "http=#{code} duration_ms=#{duration_ms}"
      )
      raise TransientError, "OpenClaw RPC returned #{code}"
    end
  end

  private

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
