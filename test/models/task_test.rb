require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "valid with name, user, board, column" do
    task = Task.new(
      name: "Fresh task",
      user: users(:one),
      board: boards(:one_default),
      column: columns(:one_inbox)
    )
    assert task.valid?
  end

  test "requires a column" do
    task = Task.new(
      name: "No column",
      user: users(:one),
      board: boards(:one_default)
    )
    assert_not task.valid?
    assert_includes task.errors[:column], "must exist"
  end

  test "assigned_agent is optional" do
    task = tasks(:one)
    assert_nil task.assigned_agent
    assert task.valid?
  end

  test "assigned scope returns tasks with an agent" do
    task = tasks(:one)
    task.update!(assigned_agent: agents(:one_primary))
    assert_includes Task.assigned, task
    assert_not_includes Task.unassigned, task
  end

  test "unassigned scope returns tasks without an agent" do
    task = tasks(:two)
    assert_nil task.assigned_agent_id
    assert_includes Task.unassigned, task
    assert_not_includes Task.assigned, task
  end

  test "done? returns true only when sitting in the Done column" do
    task = tasks(:one)
    assert_not task.done?
    task.update!(column: columns(:one_done))
    assert task.done?
  end

  test "moving to Done syncs completed flag and timestamp" do
    task = tasks(:one)
    assert_not task.completed
    task.update!(column: columns(:one_done))
    task.reload
    assert task.completed
    assert task.completed_at.present?
  end

  test "moving out of Done clears completed flag" do
    task = tasks(:one)
    task.update!(column: columns(:one_done))
    assert task.reload.completed
    task.update!(column: columns(:one_inbox))
    task.reload
    assert_not task.completed
    assert_nil task.completed_at
  end

  test "assign_to_agent! updates assigned_agent" do
    task = tasks(:one)
    agent = agents(:one_primary)
    task.assign_to_agent!(agent)
    assert_equal agent, task.reload.assigned_agent
  end

  test "unassign_from_agent! nils the agent" do
    task = tasks(:one)
    task.update!(assigned_agent: agents(:one_primary))
    task.unassign_from_agent!
    assert_nil task.reload.assigned_agent
  end

  test "set_position appends within the same column" do
    board = boards(:one_default)
    column = columns(:one_inbox)
    existing_max = board.tasks.where(column_id: column.id).maximum(:position) || 0
    new_task = board.tasks.create!(name: "Appended", user: users(:one), column: column)
    assert_equal existing_max + 1, new_task.position
  end
end
