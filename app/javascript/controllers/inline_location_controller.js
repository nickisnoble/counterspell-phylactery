import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="inline-location"
export default class extends Controller {
  static targets = ["form", "select", "toggle"]

  connect() {
    this.formTarget.classList.add("hidden")
  }

  toggle(event) {
    event.preventDefault()
    this.formTarget.classList.toggle("hidden")
  }

  cancel(event) {
    event.preventDefault()
    this.formTarget.classList.add("hidden")
    this.formTarget.reset()
  }
}
