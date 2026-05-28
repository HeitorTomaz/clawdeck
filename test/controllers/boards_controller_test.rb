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
end
