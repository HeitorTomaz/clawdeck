require "test_helper"

class BoardTest < ActiveSupport::TestCase
  test "default_columns! creates the 5 default columns in order" do
    board = users(:one).boards.create!(name: "Fresh Board")
    board.default_columns!

    names = board.columns.order(:position).pluck(:name)
    assert_equal [ "Inbox", "Up Next", "In Progress", "In Review", "Done" ], names

    positions = board.columns.order(:position).pluck(:position)
    assert_equal [ 0, 1, 2, 3, 4 ], positions
  end

  test "default_columns! is idempotent" do
    board = users(:one).boards.create!(name: "Idempotent")
    board.default_columns!
    assert_no_difference -> { board.columns.count } do
      board.default_columns!
    end
  end

  test "has_many :columns ordered by position" do
    board = boards(:one_default)
    positions = board.columns.pluck(:position)
    assert_equal positions.sort, positions
  end

  test "destroying a board destroys its columns" do
    board = users(:one).boards.create!(name: "Disposable")
    board.default_columns!
    column_ids = board.columns.pluck(:id)
    board.destroy!
    column_ids.each { |id| assert_nil Column.find_by(id: id) }
  end
end
