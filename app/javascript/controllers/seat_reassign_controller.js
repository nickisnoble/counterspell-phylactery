import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit(event) {
    // Auto-submit the form when select changes
    event.target.form.requestSubmit()
  }
}
