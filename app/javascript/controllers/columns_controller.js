import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Connects to data-controller="columns"
//
// Mounted on the board's columns wrapper (#board-columns) and handles:
//   - Opening the "Manage columns" modal
//   - Drag-to-reorder of columns themselves (using the drag handle on each
//     column header). On drop, POSTs the new order to the reorder endpoint
//     and rolls back the optimistic move if the server returns an error.
export default class extends Controller {
  static values = { reorderUrl: String }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: ".column-drag-handle",
      draggable: ".column-card",
      filter: ".board-add-column",
      ghostClass: "sortable-ghost",
      dragClass: "sortable-drag",
      onEnd: this.handleEnd.bind(this)
    })
  }

  disconnect() {
    if (this.sortable) this.sortable.destroy()
  }

  openManageModal(event) {
    if (event) event.preventDefault()
    const modal = document.getElementById("manage-columns-modal")
    if (modal) modal.classList.remove("hidden")
  }

  async handleEnd(event) {
    if (!this.hasReorderUrlValue) return
    if (event.oldIndex === event.newIndex) return

    // Capture order in case we need to roll back
    const previousOrder = Array.from(this.element.querySelectorAll(".column-card"))
      .map(el => el.dataset.columnId)

    // Move the manage-modal row to mirror the new order
    this._syncManageModalOrder(previousOrder)

    try {
      const response = await fetch(this.reorderUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "text/vnd.turbo-stream.html, application/json",
          "X-CSRF-Token": this._csrfToken()
        },
        body: JSON.stringify({ order: previousOrder })
      })

      if (!response.ok) {
        this._showToast("Couldn't save column order. Reverting.", "error")
        this._revertOrder(event)
        return
      }

      // If server returned a turbo stream, apply it (e.g. position bumps).
      const ct = response.headers.get("content-type") || ""
      if (ct.includes("turbo-stream")) {
        const html = await response.text()
        if (html.trim().length) Turbo.renderStreamMessage(html)
      }
    } catch (err) {
      console.error("Column reorder failed:", err)
      this._showToast("Network error. Reverting.", "error")
      this._revertOrder(event)
    }
  }

  _revertOrder(event) {
    // Put the dragged element back to its old index
    const parent = this.element
    const moved = event.item
    const siblings = Array.from(parent.querySelectorAll(".column-card"))
    const before = siblings[event.oldIndex]
    if (before && before !== moved) {
      parent.insertBefore(moved, before)
    } else {
      parent.appendChild(moved)
    }
  }

  _syncManageModalOrder(order) {
    const list = document.getElementById("manage-columns-list")
    if (!list) return
    order.forEach(id => {
      const row = list.querySelector(`#manage-column-${id}`)
      if (row) list.appendChild(row)
    })
  }

  _csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content || ""
  }

  _showToast(message, kind = "error") {
    const container = document.getElementById("toast-container")
    if (!container) {
      console.warn("Toast container missing:", message)
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
