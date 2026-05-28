require "test_helper"

class Api::V1::Agent::TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @agent = agents(:one)
    @task = tasks(:one)
    @board = @task.board
    @column = @task.column
    @raw_token = "test_token_one_abc123def456"
    @auth_header = { "X-Agent-Token" => @raw_token }
  end

  test "unauthorized without token" do
    get api_v1_agent_tasks_url
    assert_response :unauthorized
  end

  test "index returns task list with new shape" do
    get api_v1_agent_tasks_url, headers: @auth_header
    assert_response :success

    body = response.parsed_body
    assert_kind_of Array, body

    task = body.first
    assert task.key?("column_id")
    assert task.key?("column_name")
    assert task.key?("assigned_agent")
    # Legacy fields removed
    assert_not task.key?("status")
    assert_not task.key?("assigned_to_agent")
  end

  test "index filters by column_id" do
    get api_v1_agent_tasks_url(column_id: @column.id), headers: @auth_header
    assert_response :success
    assert response.parsed_body.all? { |t| t["column_id"] == @column.id }
  end

  test "index filters by column_name" do
    get api_v1_agent_tasks_url(column_name: @column.name), headers: @auth_header
    assert_response :success
    assert response.parsed_body.all? { |t| t["column_name"] == @column.name }
  end

  test "index ignores legacy status param" do
    get api_v1_agent_tasks_url(status: "in_progress"), headers: @auth_header
    assert_response :success
    # status param is silently ignored — caller still gets all their tasks
  end

  test "update moves task by column_id" do
    other_column = @board.columns.where.not(id: @column.id).first
    skip "need a second column to move to" unless other_column

    patch api_v1_agent_task_url(@task),
          params: { task: { column_id: other_column.id } },
          headers: @auth_header
    assert_response :success
    assert_equal other_column.id, response.parsed_body["column_id"]
    assert_equal other_column.id, @task.reload.column_id
  end

  test "update moves task by column_name" do
    other_column = @board.columns.where.not(id: @column.id).first
    skip "need a second column to move to" unless other_column

    patch api_v1_agent_task_url(@task),
          params: { column_name: other_column.name },
          headers: @auth_header
    assert_response :success
    assert_equal other_column.id, @task.reload.column_id
  end

  test "update rejects column from a different board" do
    other_board = boards(:two)
    foreign_col = other_board.columns.first
    skip "no foreign column available" unless foreign_col

    patch api_v1_agent_task_url(@task),
          params: { column_id: foreign_col.id },
          headers: @auth_header
    assert_response :unprocessable_entity
  end

  test "serializer exposes assigned_agent object" do
    @task.update!(assigned_agent: @agent)
    get api_v1_agent_task_url(@task), headers: @auth_header
    assert_response :success

    body = response.parsed_body
    assert body["assigned_agent"].is_a?(Hash)
    assert_equal @agent.id, body["assigned_agent"]["id"]
    assert_equal @agent.name, body["assigned_agent"]["name"]
  end

  test "serializer exposes nil assigned_agent when none" do
    @task.update!(assigned_agent: nil)
    get api_v1_agent_task_url(@task), headers: @auth_header
    assert_response :success
    assert_nil response.parsed_body["assigned_agent"]
  end

  test "create requires task params and uses default column when omitted" do
    post api_v1_agent_tasks_url,
         params: { task: { name: "Defaulted", board_id: @board.id } },
         headers: @auth_header
    assert_response :created
    assert response.parsed_body["column_id"].present?
  end

  test "create accepts explicit column_name" do
    post api_v1_agent_tasks_url,
         params: { task: { name: "Named", board_id: @board.id, column_name: @column.name } },
         headers: @auth_header
    assert_response :created
    assert_equal @column.id, response.parsed_body["column_id"]
  end
end
