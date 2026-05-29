import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Connects to data-controller="sortable-columns"
//
// Drag-to-reorder of the rows inside the "Manage columns" modal. Mirrors the
// order back to the kanban board's columns (#board-columns) so both stay in
// sync, then POSTs the order to the reorder endpoint.
export default class extends Controller {
  static values = { url: String }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: ".drag-handle",
      ghostClass: "sortable-ghost",
      dragClass: "sortable-drag",
      onEnd: this.handleEnd.bind(this)
    })
  }

  disconnect() {
    if (this.sortable) this.sortable.destroy()
  }

  async handleEnd(event) {
    if (!this.hasUrlValue) return
    if (event.oldIndex === event.newIndex) return

    const order = Array.from(this.element.querySelectorAll("[data-column-id]"))
      .map(el => el.dataset.columnId)

    // Mirror order back to the kanban
    const board = document.getElementById("board-columns")
    if (board) {
      order.forEach(id => {
        const col = board.querySelector(`#board-column-${id}`)
        if (col) board.appendChild(col)
      })
    }

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "text/vnd.turbo-stream.html, application/json",
          "X-CSRF-Token": this._csrfToken()
        },
        body: JSON.stringify({ order })
      })

      if (!response.ok) {
        this._showToast("Couldn't save column order.", "error")
      } else {
        const ct = response.headers.get("content-type") || ""
        if (ct.includes("turbo-stream")) {
          const html = await response.text()
          if (html.trim().length) Turbo.renderStreamMessage(html)
        }
      }
    } catch (err) {
      console.error("Column reorder failed:", err)
      this._showToast("Network error while saving order.", "error")
    }
  }

  _csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content || ""
  }

  _showToast(message, kind = "error") {
    const container = document.getElementById("toast-container")
    if (!container) return
    const toast = document.createElement("div")
    const bg = kind === "error" ? "bg-status-error/20" : "bg-status-success/20"
    const fg = kind === "error" ? "text-status-error" : "text-status-success"
    toast.className = `px-3 py-2 text-xs font-medium rounded-lg border border-white/[0.06] ${bg} ${fg}`
    toast.setAttribute("data-controller", "flash")
    toast.textContent = message
    container.appendChild(toast)
  }
}
