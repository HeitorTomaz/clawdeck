require "test_helper"

class BoardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @board = boards(:one_default)
    sign_in_as @user
  end

  test "GET list renders list view" do
    get list_board_url(@board)
    assert_response :success
    assert_select "[data-list-view]"
  end

  test "GET show filters tasks by q param" do
    col = @board.columns.first
    hit = Task.create!(board: @board, column: col, user: @user, name: "Neymar grande")
    miss = Task.create!(board: @board, column: col, user: @user, name: "Outro")

    get board_url(@board, q: "neymar")
    assert_response :success
    body = @response.body
    assert_includes body, "Neymar grande"
    assert_not_includes body, "Outro"
  end
end
