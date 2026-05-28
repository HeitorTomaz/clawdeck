require "test_helper"

class ColumnTest < ActiveSupport::TestCase
  test "valid with board, name, position" do
    board = boards(:one_default)
    column = board.columns.build(name: "Backlog", position: 99)
    assert column.valid?
  end

  test "name uniqueness scoped to board" do
    board = boards(:one_default)
    dup = board.columns.build(name: "Inbox", position: 99)
    assert_not dup.valid?
    assert_includes dup.errors[:name], "has already been taken"
  end

  test "same name allowed across different boards" do
    other_board = boards(:two_default)
    column = other_board.columns.build(name: "Up Next", position: 99)
    assert column.valid?
  end

  test "position uniqueness scoped to board" do
    board = boards(:one_default)
    dup = board.columns.build(name: "Brand new", position: columns(:one_inbox).position)
    assert_not dup.valid?
    assert_includes dup.errors[:position], "has already been taken"
  end

  test "default scope orders by position ascending" do
    board = boards(:one_default)
    positions = board.columns.pluck(:position)
    assert_equal positions.sort, positions
  end

  test "delete blocked when there are tasks" do
    column = columns(:one_inbox)
    # tasks(:one) sits in this column via the fixture.
    assert column.tasks.exists?, "fixture precondition: column has tasks"
    assert_not column.destroy
    assert column.errors[:base].any?, "expected restrict_with_error to populate :base"
  end

  test "assigned_agent is optional" do
    column = columns(:one_inbox)
    assert_nil column.assigned_agent
    assert column.valid?
  end

  test "assigning an agent persists the link" do
    column = columns(:one_up_next)
    agent = agents(:one_primary)
    column.update!(assigned_agent: agent)
    assert_equal agent, column.reload.assigned_agent
  end
end
