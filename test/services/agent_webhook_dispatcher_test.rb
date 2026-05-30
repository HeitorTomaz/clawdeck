require "test_helper"

class AgentWebhookDispatcherTest < ActiveSupport::TestCase
  setup do
    @task = tasks(:one)
    @agent = agents(:one_primary)
    @agent.update!(webhook_agent_id: "main")
  end

  def fake_response(code, body = "{\"ok\":true}")
    Struct.new(:code, :body).new(code.to_s, body)
  end

  def with_env(url: "http://gw/hooks/agent", token: "tok")
    prev_url = ENV["OPENCLAW_HOOKS_URL"]
    prev_token = ENV["OPENCLAW_HOOKS_TOKEN"]
    ENV["OPENCLAW_HOOKS_URL"] = url
    ENV["OPENCLAW_HOOKS_TOKEN"] = token
    yield
  ensure
    ENV["OPENCLAW_HOOKS_URL"] = prev_url
    ENV["OPENCLAW_HOOKS_TOKEN"] = prev_token
  end

  test "no-ops with warning when env vars missing" do
    with_env(url: nil, token: nil) do
      dispatcher = AgentWebhookDispatcher.new(@task, @agent, http_client: ->(*) { fake_response(200) })
      assert_equal :skipped, dispatcher.call
    end
  end

  test "posts /hooks/agent body with bearer auth and returns 2xx response" do
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
    assert_equal "http://gw/hooks/agent", captured[:url]
    assert_equal "tok", captured[:token]
    parsed = JSON.parse(captured[:body])
    assert_equal @agent.webhook_agent_id, parsed["agentId"]
    assert_equal "clawdeck-task-#{@task.id}", parsed["name"]
    assert parsed["message"].present?
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

  test "interpolates known placeholders and leaves unknown ones untouched" do
    dispatcher = AgentWebhookDispatcher.new(@task, @agent)
    result = dispatcher.send(:render_template, "Run {{task.name}} id={{task.id}} x={{unknown}}")
    assert_includes result, "Run #{@task.name}"
    assert_includes result, "id=#{@task.id}"
    assert_includes result, "x={{unknown}}"
  end
end
