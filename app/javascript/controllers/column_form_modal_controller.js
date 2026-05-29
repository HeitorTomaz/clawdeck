import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="column-form-modal"
//
// Closes the column form turbo frame by emptying it. Works for both
// "New column" and "Edit column" modals since both load into the same
// #column_form_modal turbo frame.
export default class extends Controller {
  close(event) {
    if (event) event.preventDefault()
    const frame = document.getElementById("column_form_modal")
    if (frame) frame.innerHTML = ""
  }
}
