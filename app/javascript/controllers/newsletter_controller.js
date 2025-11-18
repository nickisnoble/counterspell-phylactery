import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "modal", "confirmButton", "cancelButton"]
  static values = {
    wasChecked: Boolean
  }

  connect() {
    // Store initial state
    this.wasCheckedValue = this.checkboxTarget.checked
  }

  handleChange(event) {
    // If user is unchecking (was checked before, now unchecked)
    if (this.wasCheckedValue && !this.checkboxTarget.checked) {
      // Prevent form submission
      event.preventDefault()

      // Show confirmation modal
      this.showModal()

      // Temporarily restore checked state until confirmed
      this.checkboxTarget.checked = true
    } else {
      // User is checking the box - allow it
      this.wasCheckedValue = true
    }
  }

  showModal() {
    this.modalTarget.classList.remove("hidden")
  }

  hideModal() {
    this.modalTarget.classList.add("hidden")
  }

  confirm() {
    // Actually uncheck the box
    this.checkboxTarget.checked = false
    this.wasCheckedValue = false

    // Hide modal
    this.hideModal()
  }

  cancel() {
    // Keep box checked (already is)
    this.hideModal()
  }
}
