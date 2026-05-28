require "test_helper"

class ColumnsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @board = boards(:one)
    @column = columns(:inbox_one)
    post session_path, params: { email_address: @user.email_address, password: "password123" }
  end

  test "create adds a column to the board" do
    assert_difference "Column.count", 1 do
      post board_columns_path(@board), params: { column: { name: "Triage" } }
    end
  end

  test "create scoped to current user's board" do
    other_board = boards(:two)
    assert_no_difference "Column.count" do
      assert_raises(ActiveRecord::RecordNotFound) do
        post board_columns_path(other_board), params: { column: { name: "Hack" } }
      end
    end
  end

  test "update renames a column" do
    patch board_column_path(@board, @column), params: { column: { name: "Renamed" } }
    assert_equal "Renamed", @column.reload.name
  end

  test "destroy refuses when column has tasks (HTML)" do
    @board.tasks.create!(user: @user, name: "blocker", column: @column)
    assert_no_difference "Column.count" do
      delete board_column_path(@board, @column)
    end
    assert_redirected_to board_path(@board)
    assert_match(/Cannot delete/, flash[:alert])
  end

  test "destroy refuses when column has tasks (JSON)" do
    @board.tasks.create!(user: @user, name: "blocker", column: @column)
    delete board_column_path(@board, @column, format: :json)
    assert_response :unprocessable_entity
    body = response.parsed_body
    assert_equal @column.id, body["column_id"]
    assert body["task_count"].to_i.positive?
  end

  test "destroy deletes empty column" do
    empty = @board.columns.create!(name: "Empty Tmp", position: 999)
    assert_difference "Column.count", -1 do
      delete board_column_path(@board, empty)
    end
  end

  test "reorder updates positions" do
    cols = @board.columns.order(:position).to_a
    skip "need at least 2 columns to reorder" if cols.size < 2

    new_order = cols.map(&:id).reverse
    post reorder_board_columns_path(@board), params: { order: new_order }
    assert_response :ok
    assert_equal new_order, @board.columns.reload.order(:position).pluck(:id)
  end
end
