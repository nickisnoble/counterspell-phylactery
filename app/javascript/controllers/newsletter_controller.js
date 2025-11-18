import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "modal", "reasonField"]
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
      // Prevent default form behavior
      event.preventDefault()

      // Show modal to collect reason
      this.showModal()

      // Temporarily restore checked state until they submit the modal
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

  submit() {
    // Get the selected reason or custom text
    const reason = this.getSelectedReason()

    // Store the reason in a hidden field so it gets submitted with the form
    this.setUnsubscribeReason(reason)

    // Actually uncheck the box
    this.checkboxTarget.checked = false
    this.wasCheckedValue = false

    // Hide modal
    this.hideModal()
  }

  cancel() {
    // Keep box checked (already is) and just hide modal
    this.hideModal()
  }

  getSelectedReason() {
    // Check radio buttons
    const selectedRadio = this.element.querySelector('input[name="unsubscribe_reason"]:checked')
    if (selectedRadio) {
      if (selectedRadio.value === "other") {
        return this.reasonFieldTarget.value || "Other"
      }
      return selectedRadio.value
    }
    return "No reason provided"
  }

  setUnsubscribeReason(reason) {
    // Store in a data attribute or hidden field that the backend can read
    // We'll add this to the form submission
    let reasonField = this.element.querySelector('input[name="user[unsubscribe_reason]"]')
    if (!reasonField) {
      reasonField = document.createElement('input')
      reasonField.type = 'hidden'
      reasonField.name = 'user[unsubscribe_reason]'
      this.element.closest('form').appendChild(reasonField)
    }
    reasonField.value = reason
  }

  toggleOtherField(event) {
    if (event.target.value === "other") {
      this.reasonFieldTarget.classList.remove("hidden")
    } else {
      this.reasonFieldTarget.classList.add("hidden")
    }
  }
}
