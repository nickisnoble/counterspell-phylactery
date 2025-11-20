import { Controller } from "@hotwired/stimulus"

// Syncs the selected hero's role into the hidden role_selection field so the
// SeatPurchaseForm receives both required params.
export default class extends Controller {
  static targets = ["heroSelect", "roleField"]

  connect() {
    this.updateRole()
  }

  updateRole() {
    const selectedOption = this.heroSelectTarget.selectedOptions[0]
    const role = selectedOption?.dataset.role || ""
    this.roleFieldTarget.value = role
  }
}
