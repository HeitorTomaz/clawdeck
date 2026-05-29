import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="column-actions"
//
// Handles the per-column action menu (delete with confirm + toast on 422).
// The server returns 422 with JSON { detail, column_id, task_count } when a
// column still has tasks. We surface that as a toast and keep the column.
export default class extends Controller {
  static values = {
    columnId: String,
    boardId: String
  }

  confirmDelete(event) {
    event.preventDefault()
    event.stopPropagation()

    const btn = event.currentTarget
    const columnName = btn.dataset.columnName || "this column"
    const taskCount = parseInt(btn.dataset.taskCount || "0", 10)

    let message
    if (taskCount > 0) {
      message = `Column "${columnName}" has ${taskCount} task${taskCount === 1 ? "" : "s"}. Move or delete them first.`
      this._showToast(message, "error")
      return
    }

    if (!window.confirm(`Delete column "${columnName}"?`)) return

    this._performDelete(columnName)
  }

  async _performDelete(columnName) {
    const url = `/boards/${this.boardIdValue}/columns/${this.columnIdValue}`
    try {
      const response = await fetch(url, {
        method: "DELETE",
        headers: {
          "Accept": "text/vnd.turbo-stream.html, application/json",
          "X-CSRF-Token": this._csrfToken()
        }
      })

      if (response.status === 422) {
        // Server says the column still has tasks
        let detail = `Column "${columnName}" still has tasks. Move or delete them first.`
        try {
          const data = await response.json()
          if (data?.detail) {
            const count = data.task_count
            detail = count != null
              ? `Column has ${count} task${count === 1 ? "" : "s"}. Move or delete them first.`
              : data.detail
          }
        } catch (_) {}
        this._showToast(detail, "error")
        return
      }

      if (!response.ok) {
        this._showToast("Couldn't delete column.", "error")
        return
      }

      const ct = response.headers.get("content-type") || ""
      if (ct.includes("turbo-stream")) {
        const html = await response.text()
        if (html.trim().length) Turbo.renderStreamMessage(html)
      } else {
        // Fallback: remove the column locally
        document.getElementById(`board-column-${this.columnIdValue}`)?.remove()
        document.getElementById(`manage-column-${this.columnIdValue}`)?.remove()
      }
    } catch (err) {
      console.error("Column delete failed:", err)
      this._showToast("Network error while deleting column.", "error")
    }
  }

  _csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content || ""
  }

  _showToast(message, kind = "error") {
    const container = document.getElementById("toast-container")
    if (!container) {
      window.alert(message)
      return
    }
    const toast = document.createElement("div")
    const bg = kind === "error" ? "bg-status-error/20" : "bg-status-success/20"
    const fg = kind === "error" ? "text-status-error" : "text-status-success"
    toast.className = `px-3 py-2 text-xs font-medium rounded-lg border border-white/[0.06] ${bg} ${fg}`
    toast.setAttribute("data-controller", "flash")
    toast.textContent = message
    container.appendChild(toast)
  }
}
