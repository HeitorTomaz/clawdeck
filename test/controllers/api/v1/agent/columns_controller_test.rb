require "test_helper"

class Api::V1::Agent::ColumnsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @agent = agents(:one)
    @board = boards(:one)
    @column = columns(:inbox_one)
    @raw_token = "test_token_one_abc123def456"
    @auth_header = { "X-Agent-Token" => @raw_token }
  end

  test "index returns columns for board ordered by position" do
    get api_v1_agent_board_columns_url(@board), headers: @auth_header
    assert_response :success

    body = response.parsed_body
    assert_kind_of Array, body
    positions = body.map { |c| c["position"] }
    assert_equal positions.sort, positions
  end

  test "index returns 401 without token" do
    get api_v1_agent_board_columns_url(@board)
    assert_response :unauthorized
  end

  test "index returns 404 for other users board" do
    other_board = boards(:two)
    get api_v1_agent_board_columns_url(other_board), headers: @auth_header
    assert_response :not_found
  end

  test "create creates a new column at end" do
    assert_difference "Column.count", 1 do
      post api_v1_agent_board_columns_url(@board),
           params: { column: { name: "Custom Column" } },
           headers: @auth_header
    end
    assert_response :created

    body = response.parsed_body
    assert_equal "Custom Column", body["name"]
    assert_equal @board.id, body["board_id"]
  end

  test "create rejects duplicate name in same board" do
    post api_v1_agent_board_columns_url(@board),
         params: { column: { name: @column.name } },
         headers: @auth_header
    assert_response :unprocessable_entity
  end

  test "update renames column" do
    patch api_v1_agent_board_column_url(@board, @column),
          params: { column: { name: "Renamed" } },
          headers: @auth_header
    assert_response :success
    assert_equal "Renamed", response.parsed_body["name"]
  end

  test "destroy returns 422 with task_count when column has tasks" do
    # Ensure the column has at least one task
    @board.tasks.create!(user: @user, name: "blocker", column: @column)

    task_count_before = @column.tasks.count
    assert task_count_before.positive?

    assert_no_difference "Column.count" do
      delete api_v1_agent_board_column_url(@board, @column), headers: @auth_header
    end
    assert_response :unprocessable_entity

    body = response.parsed_body
    assert_equal @column.id, body["column_id"]
    assert_equal task_count_before, body["task_count"]
    assert_match(/Column has #{task_count_before} task/, body["detail"])
  end

  test "destroy deletes empty column" do
    empty_col = @board.columns.create!(name: "Temp Empty", position: 999)

    assert_difference "Column.count", -1 do
      delete api_v1_agent_board_column_url(@board, empty_col), headers: @auth_header
    end
    assert_response :no_content
  end

  test "reorder applies positions atomically" do
    cols = @board.columns.order(:position).to_a
    skip "need at least 2 columns to reorder" if cols.size < 2

    new_order = cols.map(&:id).reverse

    post reorder_api_v1_agent_board_columns_url(@board),
         params: { order: new_order },
         headers: @auth_header
    assert_response :success

    reloaded_positions = @board.columns.reload.order(:position).pluck(:id)
    assert_equal new_order, reloaded_positions
  end

  test "reorder rejects partial order" do
    cols = @board.columns.order(:position).to_a
    skip "need at least 2 columns" if cols.size < 2

    post reorder_api_v1_agent_board_columns_url(@board),
         params: { order: [cols.first.id] },
         headers: @auth_header
    assert_response :unprocessable_entity
  end

  test "reorder rejects unknown ids" do
    post reorder_api_v1_agent_board_columns_url(@board),
         params: { order: [999_999_999] },
         headers: @auth_header
    assert_response :unprocessable_entity
  end
end
