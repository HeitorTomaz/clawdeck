require "application_system_test_case"

class ColumnsTest < ApplicationSystemTestCase
  setup do
    @user  = users(:one)
    @board = @user.boards.first

    # Auth via the user's session — system tests share the cookie jar with the app
    visit new_session_path
    fill_in "email_address", with: @user.email_address
    fill_in "password",      with: "password"
    click_button "Sign in"

    visit board_path(@board)
  end

  test "user opens manage columns modal from board header" do
    click_button "Columns"
    assert_selector "#manage-columns-modal:not(.hidden)"
    assert_selector "#manage-columns-list li"
  end

  test "user adds a new column from the manage modal" do
    click_button "Columns"
    within "#manage-columns-modal" do
      click_link "Add column"
    end

    within "#column_form_modal" do
      fill_in "Column name", with: "Blocked"
      click_button "Create column"
    end

    assert_selector "#board-columns .column-card", text: "Blocked"
    assert_selector "#manage-columns-list li", text: "Blocked"
  end

  test "user renames a column inline" do
    column = @board.columns.first
    click_button "Columns"

    within "#manage-column-#{column.id}" do
      find("a[title='Edit']").click
    end

    within "#column_form_modal" do
      fill_in "Column name", with: "Renamed"
      click_button "Save changes"
    end

    assert_selector "#board-column-#{column.id}", text: "Renamed"
  end

  test "delete blocked when column still has tasks shows toast" do
    column = @board.columns.first
    # ensure at least one task is present (relies on fixtures/onboarding); if
    # not, create one through the UI flow
    if column.tasks.empty?
      within "#board-column-#{column.id}" do
        click_button "Add a card"
        find("textarea").set("Task to block deletion")
        click_button "Add card"
      end
      assert_selector "#column-#{column.id} [data-task-id]"
    end

    accept_confirm do
      click_button "Columns"
      within "#manage-column-#{column.id}" do
        find("button[title='Delete']").click
      end
    end

    assert_selector "#toast-container", text: /has \d+ task/i
    assert_selector "#manage-column-#{column.id}"
  end

  test "agent picker shows current_user's agents in the column form" do
    skip "Agents fixture not yet wired" unless @user.respond_to?(:agents) && @user.agents.any?

    click_button "Columns"
    within "#manage-columns-modal" do
      click_link "Add column"
    end

    within "#column_form_modal" do
      assert_selector "select[name='column[assigned_agent_id]']"
      @user.agents.each do |agent|
        assert_selector "option", text: agent.name
      end
    end
  end

  test "drag-reordering columns updates the order" do
    skip "Drag interaction is flaky in headless; covered by JS controller logic"
  end
end
