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

  test "filter_by q matches name or description ILIKE" do
    board = boards(:one_default)
    match_name = Task.create!(board: board, column: board.columns.first, user: users(:one), name: "Neymar treina hoje")
    match_desc = Task.create!(board: board, column: board.columns.first, user: users(:one), name: "Random", description: "Vai ter Neymar no jogo")
    nope = Task.create!(board: board, column: board.columns.first, user: users(:one), name: "Outro time")

    result = Task.filter_by({ q: "neymar" }, board: board)
    assert_includes result, match_name
    assert_includes result, match_desc
    assert_not_includes result, nope
  end

  test "filter_by tag uses ANY-of when single, AND when multiple" do
    board = boards(:one_default)
    col = board.columns.first
    t_a = Task.create!(board: board, column: col, user: users(:one), name: "A", tags: ["categoria:selecao", "topic:x"])
    t_b = Task.create!(board: board, column: col, user: users(:one), name: "B", tags: ["categoria:selecao"])
    t_c = Task.create!(board: board, column: col, user: users(:one), name: "C", tags: ["categoria:brasileirao"])

    single = Task.filter_by({ tag: "categoria:selecao" }, board: board)
    assert_equal [t_a, t_b].map(&:id).sort, single.pluck(:id).sort

    both = Task.filter_by({ tag: ["categoria:selecao", "topic:x"] }, board: board)
    assert_equal [t_a.id], both.pluck(:id)
  end

  test "filter_by column resolves by name to id" do
    board = boards(:one_default)
    inbox = board.columns.find_by(name: "Inbox")
    done = board.columns.find_by(name: "Done")
    in_inbox = Task.create!(board: board, column: inbox, user: users(:one), name: "I")
    in_done = Task.create!(board: board, column: done, user: users(:one), name: "D")

    result = Task.filter_by({ column: "Inbox" }, board: board)
    assert_includes result, in_inbox
    assert_not_includes result, in_done
  end

  test "filter_by touched_by joins TaskActivity actor_type" do
    board = boards(:one_default)
    col = board.columns.first
    task = Task.create!(board: board, column: col, user: users(:one), name: "T")
    TaskActivity.create!(task: task, actor_type: "moderador", action: "moved", new_value: "Rejeitado")

    result = Task.filter_by({ touched_by: "moderador" }, board: board)
    assert_includes result, task
  end

  test "filter_by combines dimensions with AND" do
    board = boards(:one_default)
    col = board.columns.first
    hit = Task.create!(board: board, column: col, user: users(:one), name: "Neymar", tags: ["categoria:selecao"])
    miss_tag = Task.create!(board: board, column: col, user: users(:one), name: "Neymar", tags: ["categoria:outros"])

    result = Task.filter_by({ q: "neymar", tag: "categoria:selecao" }, board: board)
    assert_equal [hit.id], result.pluck(:id)
  end
end
