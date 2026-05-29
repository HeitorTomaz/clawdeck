require "test_helper"

class AgentWebhookDispatcherTest < ActiveSupport::TestCase
  setup do
    @task = tasks(:one)
    @agent = agents(:one_primary)
    @agent.update!(webhook_cron_id: "11111111-2222-3333-4444-555555555555")
  end

  def fake_response(code, body = "{\"ok\":true}")
    Struct.new(:code, :body).new(code.to_s, body)
  end

  def with_env(url: "http://gw/api/v1/admin/rpc", token: "tok")
    prev_url = ENV["OPENCLAW_RPC_URL"]
    prev_token = ENV["OPENCLAW_GATEWAY_TOKEN"]
    ENV["OPENCLAW_RPC_URL"] = url
    ENV["OPENCLAW_GATEWAY_TOKEN"] = token
    yield
  ensure
    ENV["OPENCLAW_RPC_URL"] = prev_url
    ENV["OPENCLAW_GATEWAY_TOKEN"] = prev_token
  end

  test "no-ops with warning when env vars missing" do
    with_env(url: nil, token: nil) do
      received = []
      dispatcher = AgentWebhookDispatcher.new(@task, @agent, http_client: ->(*) { fake_response(200) })
      assert_equal :skipped, dispatcher.call
    end
  end

  test "posts JSON-RPC body with bearer auth and returns 2xx response" do
    captured = {}
    client = ->(url, body, token) {
      captured[:url] = url
      captured[:body] = body
      captured[:token] = token
      fake_response(200)
    }
    with_env do
      response = AgentWebhookDispatcher.new(@task, @agent, http_client: client).call
      assert_equal "200", response.code
    end
    assert_equal "http://gw/api/v1/admin/rpc", captured[:url]
    assert_equal "tok", captured[:token]
    parsed = JSON.parse(captured[:body])
    assert_equal "cron.run", parsed["method"]
    assert_equal @agent.webhook_cron_id, parsed.dig("params", "id")
    assert_match(/\Aclawdeck-#{@task.id}-[0-9a-f]+\z/, parsed["id"])
  end

  test "raises TransientError on 5xx" do
    client = ->(*) { fake_response(503, "unavailable") }
    with_env do
      assert_raises(AgentWebhookDispatcher::TransientError) do
        AgentWebhookDispatcher.new(@task, @agent, http_client: client).call
      end
    end
  end

  test "raises PermanentError on 4xx" do
    client = ->(*) { fake_response(401, "unauthorized") }
    with_env do
      assert_raises(AgentWebhookDispatcher::PermanentError) do
        AgentWebhookDispatcher.new(@task, @agent, http_client: client).call
      end
    end
  end
end
